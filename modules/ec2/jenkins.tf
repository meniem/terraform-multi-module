
### Random provider - for generating a password to for Jenkins server
provider "random" {
  version = "~> 3.1"
}

### Template/CloudInit provider - for installing the user data init from the script file
provider "cloudinit" {
  version = "~> 2.2"
}

#################### Security Group
# Security Group for Jenkins - Allow port 443, 8080 and 22
resource "aws_security_group" "jenkins_security_group" {
  name        = var.sg_info.jenkins_sg_name
  description = var.sg_info.jenkins_sg_description
  vpc_id      = var.vpc_id
  lifecycle { create_before_destroy = true }

  ## Ingress

  #HTTPS
  ingress {
    protocol    = var.sg_info.tcp_prot
    from_port   = var.sg_info.https
    to_port     = var.sg_info.https
    cidr_blocks = ["${var.sg_info.all}"]
  }

  #Custom TCP 8080
  ingress {
    protocol    = var.sg_info.tcp_prot
    from_port   = var.sg_info.web8080
    to_port     = var.sg_info.web8080
    cidr_blocks = ["${var.sg_info.all}"]
  }

  #SSH
  ingress {
    protocol    = var.sg_info.tcp_prot
    from_port   = var.sg_info.ssh
    to_port     = var.sg_info.ssh
    cidr_blocks = ["${var.sg_info.whitelisted_ssh}"]
  }

  #Egress
  egress {
    from_port   = var.sg_info.zero
    to_port     = var.sg_info.zero
    protocol    = var.sg_info.both_prot
    cidr_blocks = ["${var.sg_info.all}"]
  }
}


#################### IAM Policy/Role
# Create IAM policy and role for Jenkins role to be attached to the ec2 instance
resource "aws_iam_role" "jenkins_role" {
  name = "jenkins_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF

}

resource "aws_iam_policy" "jenkins_policy" {
  name = "jenkins-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*",
        "ecr:*",
        "cloudtrail:LookupEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# Attach the above policy to the role
resource "aws_iam_role_policy_attachment" "role-attach" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = aws_iam_policy.jenkins_policy.arn
}

#################### Key pair
# Generate a key pair to be attached to the instance, using TLS provider
resource "tls_private_key" "jenkins" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create an AWS key pair based on the key generated above
resource "aws_key_pair" "jenkins_key" {
  key_name   = "jenkins-key-${var.aws_region}"
  public_key = tls_private_key.bastion.public_key_openssh
}

# Save the public part of the generated key to AWS parameter store
resource "aws_ssm_parameter" "worker_nodes_public_key" {
  name  = "/jenkins-key-${var.aws_region}/secrets/jenkins_public_key"
  value = tls_private_key.jenkins.public_key_openssh
  type  = "SecureString"
}

# Save the private part of the generated key to AWS parameter store
resource "aws_ssm_parameter" "worker_nodes_private_key" {
  name  = "/jenkins-key-${var.aws_region}/secrets/jenkins_private_key"
  value = tls_private_key.jenkins.private_key_pem
  type  = "SecureString"
}


#################### Jenkins Admin Password
##### Generate Jenkins Password random string
resource "random_string" "jenkins_pass" {
  length  = 8
  number  = true
  lower   = true
  upper   = true
  special = false
}

# save Jenkins password in SSM parameter store
resource "aws_ssm_parameter" "ssm_jenkins_admin_password" {
  name  = var.ssm_jenkins_admin_password
  type  = var.ssm_parameter_type
  value = random_string.jenkins_pass.result
}


#################### Template provider
# Install Jenkins and plugins as user_data
resource "template_file" "jenkins_master_user_data" {
  # template = "${file("${var.files.jenkins_master}")}"
  template = file("${path.module}/install_jenkins_master.sh")
  lifecycle { create_before_destroy = true }
  vars = {
    admin_username = "admin"
    admin_password = "${random_string.jenkins_pass.result}"
    aws_region     = "${var.aws_region}"
  }
}

#################### EC2 instance deployment
# IAM Profile creation - will be attached to the server to give it permission to make EC2 insatnce interact with other resources such as ECR, EC2...etc.
resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "jenkins_profile"
  role = aws_iam_role.jenkins_role.name
  lifecycle { create_before_destroy = true }
}

# create an Elasti IP to be attached to the instance
resource "aws_eip" "master_eip" {
  instance = aws_instance.jenkins_master.id
  vpc      = true
  lifecycle { create_before_destroy = true }
}

# create master instance
resource "aws_instance" "jenkins_master" {
  ami                                  = lookup(var.aws_amis, var.aws_region)
  subnet_id                            = var.public_subnets[0]
  instance_type                        = var.instance.ec2_size
  instance_initiated_shutdown_behavior = "terminate"
  iam_instance_profile                 = aws_iam_instance_profile.jenkins_profile.id
  key_name                             = aws_key_pair.jenkins_key.key_name
  vpc_security_group_ids               = ["${aws_security_group.jenkins_security_group.id}"]
  user_data                            = template_file.jenkins_master_user_data.rendered
  root_block_device {
    volume_type           = var.instance.ebs_type
    volume_size           = var.instance.ebs_size
    delete_on_termination = "true"
  }
  lifecycle { create_before_destroy = true }
  tags = {
    Name = "Jenkins-Server"
  }
}
