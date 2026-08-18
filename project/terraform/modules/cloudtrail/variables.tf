variable "trail_name" {
  description = "Name of the CloudTrail trail. Matches the Bash implementation's TRAIL_NAME."
  type        = string
}

variable "s3_bucket_id" {
  description = "ID of the S3 bucket to attach the CloudTrail bucket policy to."
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket CloudTrail delivers logs to."
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket CloudTrail delivers logs to."
  type        = string
}

variable "account_id" {
  description = "AWS account ID, used to scope the CloudTrail write statement to AWSLogs/<account_id>/*."
  type        = string
}

variable "read_write_type" {
  description = "Management event read/write filtering: All, ReadOnly, or WriteOnly."
  type        = string
  default     = "All"

  validation {
    condition     = contains(["All", "ReadOnly", "WriteOnly"], var.read_write_type)
    error_message = "read_write_type must be one of: All, ReadOnly, WriteOnly."
  }
}

variable "tags" {
  description = "Tags to apply to the trail."
  type        = map(string)
  default     = {}
}
