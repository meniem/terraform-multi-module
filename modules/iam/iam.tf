
#################### IAM Policies/Roles - EKS Clsuter

data "aws_caller_identity" "current" {}

### EKS Cluster Role
# Create an IAM role for the EKS cluster, with the proper policies attached to it

# The trust relationship policy
data "aws_iam_policy_document" "cluster_assume_role" {
  statement {
    sid = "EKSClusterAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

# The EKS Cluster main IAM Role
resource "aws_iam_role" "eks_cluster" {
  name_prefix           = "eks-cluster-${var.environment}-${var.aws_region}"
  assume_role_policy    = data.aws_iam_policy_document.cluster_assume_role.json
  force_detach_policies = true
  tags                  = var.tags
}

# IAM role policies attachmnents
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}


# ELB Policy attached to the cluster IAM role that allows it to describe elb related resources
data "aws_iam_policy_document" "cluster_elb" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeInternetGateways"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "cluster_elb" {
  name_prefix = "RC-ELB-SL-"
  role        = aws_iam_role.eks_cluster.name
  policy      = data.aws_iam_policy_document.cluster_elb.json

  lifecycle {
    create_before_destroy = true
  }
}

### Node Groups IAM Role
# The main IAM role that will be attached to the EKS Node group
resource "aws_iam_role" "node_group_role" {
  name_prefix = "node_group_role"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "ec2.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags = {
    "alpha.eksctl.io/cluster-name"                = "eks-cluster-${var.environment}-${var.aws_region}"
    "alpha.eksctl.io/nodegroup-name"              = "node_group_role"
    "alpha.eksctl.io/nodegroup-type"              = "unmanaged"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = "eks-cluster-${var.environment}-${var.aws_region}"
    "eksctl.io/v1alpha2/nodegroup-name"           = "node_group_role"
  }
}

# IAM role policies attachmnents
resource "aws_iam_role_policy_attachment" "Chorus-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_iam_role_policy_attachment" "Chorus-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_iam_role_policy_attachment" "Chorus-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group_role.name
}

