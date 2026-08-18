variable "function_name" {
  description = "Lambda function name. Matches the Bash implementation's LAMBDA_FUNCTION_NAME."
  type        = string
  default     = "aws-iam-monitor-lambda"
}

variable "role_name" {
  description = "IAM role name for the Lambda execution role. Matches LAMBDA_ROLE_NAME."
  type        = string
  default     = "aws-iam-monitor-lambda-role"
}

variable "policy_name" {
  description = "IAM policy name for the Lambda execution policy."
  type        = string
  default     = "LambdaExecutionPolicy"
}

variable "runtime" {
  description = "Lambda runtime. Must be Python 3.11+."
  type        = string
  default     = "python3.11"

  validation {
    condition     = can(regex("^python3\\.(1[1-9]|[2-9][0-9])$", var.runtime))
    error_message = "runtime must be python3.11 or newer (e.g. python3.11, python3.12, python3.13)."
  }
}

variable "timeout" {
  description = "Lambda function timeout, in seconds. Matches the Bash implementation's hardcoded --timeout 15."
  type        = number
  default     = 15
}

variable "memory_size" {
  description = "Lambda function memory, in MB. The Bash implementation never sets this explicitly (relies on the AWS default of 128MB) — Terraform sets it explicitly for clarity."
  type        = number
  default     = 128
}

variable "lambda_source_file" {
  description = "Path to the Lambda Python source file to package. Points at the single source of truth shared with the Bash implementation: project/bash/lambda/src/lambda_function.py."
  type        = string
}

variable "audit_bucket_name" {
  description = "Name of the S3 audit history bucket (AUDIT_BUCKET env var)."
  type        = string
}

variable "audit_bucket_arn" {
  description = "ARN of the S3 audit history bucket, used to scope the S3AuditHistory IAM statement."
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS security alert topic (SNS_TOPIC_ARN env var), used to scope the PublishAlerts IAM statement."
  type        = string
}

variable "allowed_ips_raw" {
  description = "Comma-separated CIDR list passed to the Lambda as the ALLOWED_IPS env var. Empty string disables IP filtering, matching lambda_function.py's `os.environ.get(\"ALLOWED_IPS\", \"\")` default."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to the function and its IAM role/policy."
  type        = map(string)
  default     = {}
}
