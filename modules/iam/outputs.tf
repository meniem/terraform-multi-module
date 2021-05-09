
output "eks_cluster_iam_role_name" {
  description = "Name of EKS Cluster IAM role"
  value       = aws_iam_role.eks_cluster.name
}

output "node_group_iam_role_arn" {
  description = "ARN of EKS Nodes Group IAM role"
  value       = aws_iam_role.node_group_role.arn
}
