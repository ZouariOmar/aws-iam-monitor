# =========================================================
# aws-iam-monitor — Terraform root variables
#
# Defaults mirror project/bash/.env.example and each *_ctl script's
# hardcoded defaults, so a plain `terraform apply` with no tfvars
# overrides provisions an equivalent architecture under the same
# default resource names as `./awsctl --up all`.
# =========================================================

variable "aws_region" {
  description = "AWS region to deploy into. Matches the Bash implementation's AWS_REGION."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name, used for resource tagging only (does not affect resource names, matching the Bash implementation's naming, which is not parameterized by project name)."
  type        = string
  default     = "aws-iam-monitor"
}

variable "environment" {
  description = "Environment name, used for resource tagging only."
  type        = string
  default     = "production"
}

# ----- IAM -----

variable "enable_iam_sandbox" {
  description = "Create the demo IAM sandbox (ProdGroup/DevGroup/TestGroup and their 6 users), mirroring iam/res/{groups,users}.csv. Defaults to true so a plain `terraform apply` matches `./awsctl --up all`."
  type        = bool
  default     = true
}

variable "enable_iam_roles" {
  description = "Create the optional Dev/Prod/TestRole IAM roles, mirroring iam/res/roles.csv. Matches the Bash implementation's `-r/--role` flag, which is opt-in (off by default)."
  type        = bool
  default     = false
}

variable "allowed_ips" {
  description = "Trusted CIDR ranges. When non-empty: (1) an IPWhitelistPolicy Deny policy is created and attached to ProdGroup, and (2) the Lambda's ALLOWED_IPS env var enforces the same whitelist at the application layer. Empty list = no IP filtering, matching the Bash implementation's behavior when ALLOWED_IPS is unset. Equivalent to bash's ALLOWED_IPS=\"203.0.113.10/32,197.238.33.0/24\"."
  type        = list(string)
  default     = []
}

# ----- SNS -----

variable "sns_topic_name" {
  description = "SNS security alert topic name. Matches SNS_TOPIC_NAME."
  type        = string
  default     = "iam-alerts"
}

variable "sns_alert_email" {
  description = "Optional email address to subscribe to the alert topic. Matches SNS_ALERT_EMAIL. Leave empty to skip subscription creation."
  type        = string
  default     = ""
}

# ----- CloudTrail -----

variable "trail_name" {
  description = "CloudTrail trail name. Matches TRAIL_NAME."
  type        = string
  default     = "aws-iam-monitor-management-events"
}

variable "trail_read_write_type" {
  description = "Management event read/write filtering: All, ReadOnly, or WriteOnly."
  type        = string
  default     = "All"

  validation {
    condition     = contains(["All", "ReadOnly", "WriteOnly"], var.trail_read_write_type)
    error_message = "trail_read_write_type must be one of: All, ReadOnly, WriteOnly."
  }
}

variable "bucket_encryption_sse_algorithm" {
  description = "S3 server-side encryption algorithm applied to the CloudTrail log bucket and the audit history bucket."
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "aws:kms"], var.bucket_encryption_sse_algorithm)
    error_message = "bucket_encryption_sse_algorithm must be one of: AES256, aws:kms."
  }
}

# ----- Lambda -----

variable "lambda_function_name" {
  description = "Lambda function name. Matches LAMBDA_FUNCTION_NAME."
  type        = string
  default     = "aws-iam-monitor-lambda"
}

variable "lambda_role_name" {
  description = "IAM role name for the Lambda execution role. Matches LAMBDA_ROLE_NAME."
  type        = string
  default     = "aws-iam-monitor-lambda-role"
}

variable "lambda_policy_name" {
  description = "IAM policy name for the Lambda execution policy."
  type        = string
  default     = "LambdaExecutionPolicy"
}

variable "lambda_runtime" {
  description = "Lambda runtime. Must be Python 3.11 or newer."
  type        = string
  default     = "python3.11"
}

variable "lambda_timeout" {
  description = "Lambda function timeout, in seconds. Matches the Bash implementation's hardcoded value."
  type        = number
  default     = 15
}

variable "lambda_memory_size" {
  description = "Lambda function memory, in MB."
  type        = number
  default     = 128
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention period for the Lambda log group, in days. Matches the Bash implementation's `--retention-in-days 30`."
  type        = number
  default     = 30
}

# ----- EventBridge -----

variable "eventbridge_rule_name" {
  description = "EventBridge rule name. Matches RULE_NAME."
  type        = string
  default     = "aws-iam-monitor-rule"
}

# ----- CloudWatch -----

variable "enable_cloudwatch_alarms" {
  description = "Create CloudWatch alarms on the Lambda-emitted AWSIAMMonitor metrics and on Lambda errors. This is a Terraform-only enhancement beyond the Bash implementation, which emits the metrics but never alarms on them."
  type        = bool
  default     = true
}
