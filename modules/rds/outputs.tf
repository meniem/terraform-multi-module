output "rds_cluster_id" {
  value       = aws_rds_cluster.rdsaurora.id
  description = "The RDS Cluster Identifier"
}

output "rds_cluster_arn" {
  value       = aws_rds_cluster.rdsaurora.arn
  description = "Amazon Resource Name (ARN) of cluster"
}

output "rds_cluster_endpoint" {
  value       = aws_rds_cluster.rdsaurora.endpoint
  description = "The DNS address of the RDS instance"
}

output "rds_instance_identifier" {
  value       = aws_rds_cluster_instance.AuroraInstance[0].identifier
  description = "The identifier for the RDS instance"
}

output "rds_instance_endpoint" {
  value       = aws_rds_cluster_instance.AuroraInstance[0].endpoint
  description = "The DNS address of the RDS instance"
}
