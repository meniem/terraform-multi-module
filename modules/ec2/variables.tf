
variable "aws_region" {
  description = "AWS region."
}

variable "environment" {
  description = "Environment."
}

variable "tags" {
  description = "tags to propogate to all supported resources"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "public_subnets" {
  type        = list(string)
  description = "The public subnets in the VPC"
}

# AMI's from https://aws.amazon.com/amazon-linux-ami/ (HVM EBS Backed 64-bit)
variable "aws_amis" {
  default = {
    us-east-1 = "ami-0747bdcabd34c712a"
    us-west-1 = "ami-0dd655843c87b6930"
    us-west-2 = "ami-06d51e91cea0dac8d"
  }
}

# Security group information
variable "sg_info" {
  default = {
    jenkins_sg_name        = "Jenkins-SG-1"
    bastion_sg_name        = "Bastion-SG-1"
    jenkins_sg_description = "EC2 allowed ports, protocols, and IPs for Jenkins"
    bastion_sg_description = "Allow port 22 to Bastion Host"
    https                  = "443"
    ssh                    = "22"
    web8080                = "8080"
    zero                   = "0"
    all                    = "0.0.0.0/0"
    whitelisted_ssh        = "0.0.0.0/0"
    tcp_prot               = "tcp"
    udp_prot               = "udp"
    both_prot              = "-1"
  }
}

# Instance configuration
variable "instance" {
  default = {
    ec2_size = "t2.medium"
    ebs_type = "gp2"
    ebs_size = "30"
  }
}

variable "ssm_jenkins_admin_password" {
  type        = string
  default     = "/secrets/jenkins/admin_password"
  description = "Jenkins Admin password"
}

variable "ssm_parameter_type" {
  type        = string
  default     = "SecureString"
  description = "SSM secure string type"
}

variable "bastion_ami_id" {
  type        = string
  default     = "ami-09e67e426f25ce0d7"
  description = "Bastion Host AMI ID"
}

variable "bastion_instance_type" {
  type        = string
  default     = "t2.nano"
  description = "Bastion Host Instance Type"
}
