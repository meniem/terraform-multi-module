
### TLS provider - for generating an AWS KEy Pair
provider "tls" {
  version = "~> 3.1"
}

#################### Security Group
# SG for allowing port 22 that will be attached to tthe bastion host
resource "aws_security_group" "bastion_security_group" {
  name        = var.sg_info.bastion_sg_name
  description = var.sg_info.bastion_sg_description
  vpc_id      = var.vpc_id
  lifecycle { create_before_destroy = true }

  ## Ingress - Allow SSH
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

#################### EC2 Key Pair
# Generate a key pair to be attached to the instance, using TLS provider
resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create an AWS key pair based on the key generated above
resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion-key-${var.aws_region}"
  public_key = tls_private_key.bastion.public_key_openssh
}

# Save the public part of the generated key to AWS parameter store
resource "aws_ssm_parameter" "bastion_public_key" {
  name  = "/bastion-key-${var.aws_region}/secrets/bastion_public_key"
  value = tls_private_key.bastion.public_key_openssh
  type  = "SecureString"
}

# Save the private part of the generated key to AWS parameter store
resource "aws_ssm_parameter" "bastion_private_key" {
  name  = "/bastion-key-${var.aws_region}/secrets/bastion_private_key"
  value = tls_private_key.bastion.private_key_pem
  type  = "SecureString"
}

#################### Create a bastion host instance for connecting to private AWS resurces
# Create an AWS EC2 nstance to be used as bastion host
resource "aws_instance" "bastion" {
  ami                         = var.bastion_ami_id # Ubuntu Server 20.04 LTS (HVM) - N.Virgina Region
  instance_type               = var.bastion_instance_type
  key_name                    = aws_key_pair.bastion_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${aws_security_group.bastion_security_group.id}"]
  subnet_id                   = var.public_subnets[0]

  tags = var.tags
}
