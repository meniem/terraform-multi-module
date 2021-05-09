
######## EC2 Key Pair ########

# Generate a new SSH Key
resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create the AWS Key Pair that will be attached to the worker nodes
resource "aws_key_pair" "nodes_key" {
  key_name   = "eks-cluster-worker-nodes-key"
  public_key = tls_private_key.this.public_key_openssh
}

# Save the SSH public key to SSM Parameter store - allow the circleci iam user to put new parameters
resource "aws_ssm_parameter" "worker_nodes_public_key" {
  name  = "/eks-cluster/secrets/nodes_public_key"
  value = tls_private_key.this.public_key_openssh
  type  = "SecureString"
}

# Save the SSH private key to SSM Parameter store
resource "aws_ssm_parameter" "worker_nodes_private_key" {
  name  = "/eks-cluster/secrets/nodes_private_key"
  value = tls_private_key.this.private_key_pem
  type  = "SecureString"
}
