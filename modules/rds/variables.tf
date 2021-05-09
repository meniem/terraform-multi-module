
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
  description = "VPC CIDR Range"
}

variable "private_subnets" {
  description = "VPC Private Subnets"
}

variable "rds_admin_user" {
  type        = string
  default     = "db_user"
  description = "RDS Admin user"
}

variable "ssm_rds_admin_password" {
  type        = string
  default     = "/secrets/rds/admin_password"
  description = "RDS Admin password"
}

variable "ssm_parameter_type" {
  type        = string
  default     = "SecureString"
  description = "SSM secure string type"
}

variable "engine" {
  description = "Aurora database engine type"
  type        = string
  default     = "aurora-postgresql"
}

variable "engine_mode" {
  description = "The database engine mode"
  type        = string
  default     = "provisioned"
}

variable "engine_version" {
  description = "Aurora postgresql engine version."
  type        = string
  default     = "12.4"
}

variable "postgres_identifier" {
  type        = string
  default     = "postgresdb"
  description = "DB Identifier"
}

variable "postgres_final_snapshot_identifier" {
  type        = string
  default     = "postgres-final-snapshot"
  description = "Final DB snapshot when this DB instance is deleted"
}

variable "skip_final_snapshot" {
  description = "Final snapshot be created on cluster destroy"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "If the DB instance has deletion protection enabled"
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "How long to keep backups for (in days)"
  type        = number
  default     = 30
}

variable "preferred_backup_window" {
  description = "When to perform DB backups"
  type        = string
  default     = "02:01-03:01"
}

variable "postgres_maintenance_window" {
  type        = string
  default     = "Sun:05:00-Sun:07:00"
  description = "Maintenance window"
}

variable "port" {
  description = "The port on which to accept connections"
  type        = string
  default     = "5432"
}

variable "storage_encrypted" {
  description = "If the underlying storage layer should be encrypted"
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "the DB modifications are applied immediately, or during the maintenance window"
  type        = bool
  default     = false
}

variable "instance_type" {
  description = "Instance type to use"
  type        = string
  default     = "db.t3.medium"
}

variable "publicly_accessible" {
  description = "the DB has a public IP address or not"
  type        = bool
  default     = false
}

variable "auto_minor_version_upgrade" {
  description = "If the minor engine upgrades will be performed automatically in the maintenance window"
  type        = bool
  default     = true
}
