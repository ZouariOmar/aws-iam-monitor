output "bucket_name" {
  description = "Name of the created S3 bucket."
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket."
  value       = aws_s3_bucket.this.arn
}

output "bucket_id" {
  description = "ID of the created S3 bucket (same as bucket_name for S3)."
  value       = aws_s3_bucket.this.id
}
