variable "bucket_name" {
  description = "Name of the S3 bucket to create."
  type        = string
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm applied by default to all objects (AES256 or aws:kms)."
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "aws:kms"], var.sse_algorithm)
    error_message = "sse_algorithm must be one of: AES256, aws:kms."
  }
}

variable "kms_key_id" {
  description = "KMS key ARN/ID to use when sse_algorithm is \"aws:kms\". Ignored otherwise."
  type        = string
  default     = null
}

variable "enable_versioning" {
  description = "Whether to enable S3 bucket versioning."
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow `terraform destroy` to delete this bucket even if it still contains objects. Mirrors the Bash implementation's `aws s3 rm --recursive` teardown step."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the bucket."
  type        = map(string)
  default     = {}
}
