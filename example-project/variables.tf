variable "aws_region" {
  description = "AWS region to deploy resources into."
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Globally unique name for the example S3 bucket."
  type        = string
}

variable "environment" {
  description = "Environment tag (e.g. dev, staging, prod)."
  type        = string
  default     = "dev"
}