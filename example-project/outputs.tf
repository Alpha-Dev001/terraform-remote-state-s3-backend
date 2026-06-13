output "example_bucket_name" {
  description = "Name of the example S3 bucket."
  value       = aws_s3_bucket.example.id
}

output "example_bucket_arn" {
  description = "ARN of the example S3 bucket."
  value       = aws_s3_bucket.example.arn
}