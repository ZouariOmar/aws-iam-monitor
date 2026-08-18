variable "rule_name" {
  description = "EventBridge rule name. Matches the Bash implementation's RULE_NAME."
  type        = string
  default     = "aws-iam-monitor-rule"
}

variable "event_pattern" {
  description = "EventBridge event pattern object (encoded to JSON internally). Defaults are wired from the root module's locals to match project/bash/event-bridge/policies/iam-event-pattern.json exactly."
  type        = any
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function to target."
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function to target (required by aws_lambda_permission)."
  type        = string
}
