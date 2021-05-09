
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

variable "vpc_cidr" {
  description = "VPC cIDR Range"
}

variable "private_subnets" {
  description = "VPC Private Subnets"
}

variable "eks_cluster_iam_role_name" {
  description = "Name of EKS Cluster IAM role"
}

variable "node_group_iam_role_arn" {
  description = "ARN of EKS Nodes Group IAM role"
}

variable "cluster_log_retention" {
  type        = string
  description = "Log retention period"
  default     = 30
}

variable "kubernetes_version" {
  type        = string
  description = "kubernetes Version"
  default     = "1.19"
}

variable "node_group_instances_type" {
  type        = string
  description = "the KB node group instance size"
  default     = "t3.medium"
}

variable "desired_capacity" {
  type        = string
  description = "the Platform desired capacity"
  default     = 2
}

variable "max_capacity" {
  type        = string
  description = "the Platform max capacity"
  default     = 5
}

variable "min_capacity" {
  type        = string
  description = "the Platform min capacity"
  default     = 2
}

