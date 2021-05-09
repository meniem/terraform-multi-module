output "cloudwatch_log_group_name" {
  description = "Name of cloudwatch log group created"
  value       = module.eks_cluster.cloudwatch_log_group_name
}

output "cluster" {
  description = "Data object retrieved of the EKS Cluster."
  value       = data.aws_eks_cluster.cluster
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster."
  value       = module.eks_cluster.cluster_arn
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = module.eks_cluster.cluster_endpoint
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster."
  value       = module.eks_cluster.cluster_iam_role_arn
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster."
  value       = module.eks_cluster.cluster_iam_role_name
}

output "cluster_id" {
  description = "The name/id of the EKS cluster."
  value       = module.eks_cluster.cluster_id
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = module.eks_cluster.cluster_oidc_issuer_url
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster."
  value       = module.eks_cluster.cluster_security_group_id
}

output "cluster_version" {
  description = "The Kubernetes server version for the EKS cluster."
  value       = module.eks_cluster.cluster_version
}

output "iam_idp_provider_arn" {
  description = "The ARN of the IAM Identity Provider"
  value       = module.eks_cluster.oidc_provider_arn
}

output "kubeconfig" {
  description = "Kubeconfig file for connecting to the cluster"
  value       = module.eks_cluster.kubeconfig
}

output "nodes_ssh_key_path" {
  description = "Path in the parameter store to find the private key for ssh access to nodes"
  value       = aws_ssm_parameter.worker_nodes_private_key.name
}

output "worker_iam_instance_profile_arns" {
  description = "default IAM instance profile ARN for EKS worker groups"
  value       = module.eks_cluster.worker_iam_instance_profile_arns
}

output "worker_iam_instance_profile_names" {
  description = "default IAM instance profile name for EKS worker groups"
  value       = module.eks_cluster.worker_iam_instance_profile_names
}

output "worker_iam_role_arn" {
  description = "default IAM role ARN for EKS worker groups"
  value       = module.eks_cluster.worker_iam_role_arn
}

output "worker_iam_role_name" {
  description = "default IAM role name for EKS worker groups"
  value       = module.eks_cluster.worker_iam_role_name
}

output "worker_security_group_id" {
  description = "Security group ID attached to the EKS workers."
  value       = module.eks_cluster.worker_security_group_id
}

output "workers_asg_arns" {
  description = "IDs of the autoscaling groups containing workers."
  value       = module.eks_cluster.workers_asg_arns
}

output "workers_asg_names" {
  description = "Names of the autoscaling groups containing workers."
  value       = module.eks_cluster.workers_asg_names
}

output "workers_default_ami_id" {
  description = "ID of the default worker group AMI"
  value       = module.eks_cluster.workers_default_ami_id
}

output "node_group_sg_id" {
  description = "ID of the default worker group AMI"
  value       = aws_security_group.node_group_to_master.id
}
