
variable "aws_region" {
  description = "AWS region."
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment."
  default     = "test"
}

variable "tags" {
  description = "tags to propogate to all supported resources"
  type        = map(any)
  default = {
    "Name"        = "tf_task"
    "Environment" = "Test"
  }
}
