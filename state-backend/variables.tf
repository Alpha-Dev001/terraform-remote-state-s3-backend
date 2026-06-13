variable "aws_region" {
  description = "AWS region where the backend resources will be created."
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = <<-EOT
    Globally unique name for the S3 bucket that will store Terraform state files.
    S3 bucket names must be globally unique across ALL AWS accounts, so pick
    something specific, e.g. "mycompany-terraform-state-prod".
  EOT
  type        = string
}

variable "lock_table_name" {
  description = "Name of the DynamoDB table used for state locking."
  type        = string
  default     = "terraform-locks"
}

variable "environment" {
  description = "Environment tag applied to all resources (e.g. shared, prod, dev)."
  type        = string
  default     = "shared"
}

variable "project" {
  description = "Project name, used for tagging resources."
  type        = string
  default     = "terraform-remote-state"
}