variable "lambda_function_name" {
  description = "Name of the monitoring Lambda function. Used to derive the log group name (/aws/lambda/<name>) and as the alarm dimension."
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention period in days. Matches the Bash implementation's `aws logs put-retention-policy --retention-in-days 30`."
  type        = number
  default     = 30
}

variable "enable_cloudwatch_alarms" {
  description = "Whether to create CloudWatch alarms on the Lambda-emitted AWSIAMMonitor metrics and on Lambda errors. This is a Terraform-only enhancement — the Bash implementation emits the underlying metrics but never creates alarms on them."
  type        = bool
  default     = true
}

variable "sns_topic_arn" {
  description = "SNS topic ARN alarms publish to. Required (non-empty) only when enable_cloudwatch_alarms is true."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to the log group."
  type        = map(string)
  default     = {}
}
