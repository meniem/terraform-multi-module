
######## Security Groups ########
# SG Access to master node from nodes group
resource "aws_security_group" "node_group_to_master" {
  name        = "node_group_to_master"
  description = "Allow inbound traffic between nodes group and master"
  vpc_id      = var.vpc_id

  ingress {
    description     = "TLS from VPC"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${module.eks_cluster.cluster_security_group_id}"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "node_group_to_master"
  }
}

# Allow access from 443 to control plane
resource "aws_security_group_rule" "https_to_control_plane" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = module.eks_cluster.cluster_security_group_id
  description       = "Allow access to the control plane endpoint from the internal network range"

  cidr_blocks = [
    var.vpc_cidr,
  ]
}
