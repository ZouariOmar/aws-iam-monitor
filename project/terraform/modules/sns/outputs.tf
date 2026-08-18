output "topic_arn" {
  description = "ARN of the SNS security alert topic."
  value       = aws_sns_topic.this.arn
}

output "topic_name" {
  description = "Name of the SNS security alert topic."
  value       = aws_sns_topic.this.name
}
