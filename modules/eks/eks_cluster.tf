
locals {
  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

# kubernetes provider to interact with the resources supported by Kubernetes

# Retrieve the ID of the EKS Cluster
data "aws_eks_cluster" "cluster" {
  name = module.eks_cluster.cluster_id
}

# Get the authentication token to communicate with the EKS cluster
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_cluster.cluster_id
}

# the K8s provider
provider "kubernetes" {
  version                = "~> 2.1"
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

################ EKS Cluster and Worker nodes

# Provision the EKS cluster and nodes using the official EKS community module with the latest satble version
module "eks_cluster" {
  # community eks module
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "15.2.0"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false
  cluster_iam_role_name           = var.eks_cluster_iam_role_name
  cluster_log_retention_in_days   = var.cluster_log_retention
  cluster_name                    = "eks-cluster-${var.environment}-${var.aws_region}"
  cluster_version                 = var.kubernetes_version
  vpc_id                          = var.vpc_id
  write_kubeconfig                = true

  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler",
  ]

  subnets = var.private_subnets

  tags = merge(
    local.tags,
    {
      Role    = "kubernetes cluster - ${var.environment}"
      Service = "eks"
    },
  )
  # Create the EKS node group that will registred to the cluster
  node_groups = {
    eks_ng = {
      name             = "eks-nodes-${var.environment}-${var.aws_region}"
      desired_capacity = var.desired_capacity
      max_capacity     = var.max_capacity
      min_capacity     = var.min_capacity
      disk_size        = 50
      iam_role_arn     = var.node_group_iam_role_arn
      key_name         = aws_key_pair.nodes_key.key_name
      subnets          = var.private_subnets
      instance_types = [
        "${var.node_group_instances_type}"
      ]

      k8s_labels = {
        environment = "${var.environment}"
      }

      source_security_group_ids = [
        "${aws_security_group.node_group_to_master.id}",
      ]

      tags = [
        {
          key                 = "Role"
          value               = "kubernetes nodes - ${var.environment}"
          propagate_at_launch = true
        },
        {
          key                 = "k8s.io/cluster-autoscaler/eks-cluster-${var.environment}-${var.aws_region}"
          value               = "owned"
          propagate_at_launch = true
        },
        {
          key                 = "k8s.io/cluster-autoscaler/enabled"
          value               = "true"
          propagate_at_launch = true
        },
      ]

    },

  }

}
