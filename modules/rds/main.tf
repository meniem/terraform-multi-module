
data "aws_availability_zones" "available_az" {}

#################### RDS Cluster Admin Password
##### Generate Jenkins Password random string
resource "random_string" "rds_admin_password" {
  length  = 16
  number  = true
  lower   = true
  upper   = true
  special = false
}

# save RDS Admin password in SSM parameter store
resource "aws_ssm_parameter" "ssm_rds_admin_password" {
  name  = var.ssm_rds_admin_password
  type  = var.ssm_parameter_type
  value = random_string.rds_admin_password.result
}

#################### Provision RDS Amazon Aurora Cluster with PostgreSQL compatibility
# Create the RDS Cluster based on Postgres 12.x engine
resource "aws_rds_cluster" "rdsaurora" {
  cluster_identifier           = "${var.environment}-aurora-postgres-${var.aws_region}"
  source_region                = var.aws_region
  engine                       = var.engine
  engine_mode                  = var.engine_mode
  engine_version               = var.engine_version
  database_name                = var.postgres_identifier
  master_username              = var.rds_admin_user
  master_password              = random_string.rds_admin_password.result
  final_snapshot_identifier    = var.postgres_final_snapshot_identifier
  skip_final_snapshot          = var.skip_final_snapshot
  deletion_protection          = var.deletion_protection
  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.postgres_maintenance_window
  port                         = var.port
  db_subnet_group_name         = aws_db_subnet_group.postgres_subnet_group.name
  vpc_security_group_ids       = aws_security_group.postgres_security_group.*.id
  storage_encrypted            = var.storage_encrypted
  apply_immediately            = var.apply_immediately

  tags = var.tags
}

# Create the RDS cluster instances in Multi-AZ
resource "aws_rds_cluster_instance" "AuroraInstance" {
  count                        = 2
  identifier                   = "${var.environment}-aurora-postgres-${count.index}"
  cluster_identifier           = aws_rds_cluster.rdsaurora.id
  engine                       = var.engine
  engine_version               = var.engine_version
  instance_class               = var.instance_type
  publicly_accessible          = var.publicly_accessible
  db_subnet_group_name         = aws_db_subnet_group.postgres_subnet_group.name
  preferred_maintenance_window = var.postgres_maintenance_window
  apply_immediately            = var.apply_immediately
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  tags                         = var.tags
}

# Create the RDS Subnets group, with 2 private subnets in 2 differen AZs
resource "aws_db_subnet_group" "postgres_subnet_group" {
  name       = "postgres_subnets"
  subnet_ids = [var.private_subnets[0], var.private_subnets[1]]

  tags = var.tags
}

# The RDS Security group that allow port 5432 within the VPC
resource "aws_security_group" "postgres_security_group" {
  name        = "postgres_security_group_${var.environment}"
  description = "Postgres security group access ${var.environment}"
  vpc_id      = var.vpc_id

  tags = var.tags

  ingress {
    protocol    = "tcp"
    from_port   = 5432
    to_port     = 5432
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
