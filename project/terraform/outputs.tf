output "cloudtrail_name" {
  description = "Name of the CloudTrail trail."
  value       = module.cloudtrail.trail_name
}

output "cloudtrail_bucket_name" {
  description = "Name of the S3 bucket CloudTrail delivers management event logs to."
  value       = module.s3_cloudtrail.bucket_name
}

output "audit_bucket_name" {
  description = "Name of the S3 bucket the Lambda function stores IAM audit history in."
  value       = module.s3_audit.bucket_name
}

output "sns_topic_arn" {
  description = "ARN of the SNS security alert topic."
  value       = module.sns.topic_arn
}

output "lambda_function_name" {
  description = "Name of the monitoring Lambda function."
  value       = module.lambda.function_name
}

output "lambda_function_arn" {
  description = "ARN of the monitoring Lambda function."
  value       = module.lambda.function_arn
}

output "eventbridge_rule_name" {
  description = "Name of the EventBridge rule."
  value       = module.eventbridge.rule_name
}

output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule."
  value       = module.eventbridge.rule_arn
}

output "lambda_role_arn" {
  description = "ARN of the Lambda execution role."
  value       = module.lambda.role_arn
}
