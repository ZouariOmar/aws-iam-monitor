output "log_group_name" {
  description = "Name of the Lambda CloudWatch Log Group."
  value       = aws_cloudwatch_log_group.lambda.name
}

output "log_group_arn" {
  description = "ARN of the Lambda CloudWatch Log Group."
  value       = aws_cloudwatch_log_group.lambda.arn
}
