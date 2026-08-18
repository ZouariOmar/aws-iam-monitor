variable "topic_name" {
  description = "Name of the SNS security alert topic. Matches the Bash implementation's SNS_TOPIC_NAME."
  type        = string
  default     = "iam-alerts"
}

variable "alert_email" {
  description = "Optional email address to subscribe to the alert topic. Leave empty to skip subscription creation, matching the Bash implementation's optional SNS_ALERT_EMAIL. AWS requires manual confirmation via the emailed confirmation link — Terraform cannot auto-confirm it."
  type        = string
  default     = ""
}

variable "account_id" {
  description = "AWS account ID, used to scope the topic policy's default statement."
  type        = string
}

variable "aws_region" {
  description = "AWS region the topic is created in."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the topic."
  type        = map(string)
  default     = {}
}
