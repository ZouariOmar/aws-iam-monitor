variable "account_id" {
  description = "AWS account ID, used as the trust-policy principal for optional IAM roles."
  type        = string
}

variable "enable_iam_sandbox" {
  description = "Whether to create the demo IAM sandbox (ProdGroup/DevGroup/TestGroup and their 6 users), mirroring project/bash/iam/res/{groups,users}.csv. Defaults to true to match `./awsctl --up all` behavior."
  type        = bool
  default     = true
}

variable "enable_iam_roles" {
  description = "Whether to create the optional Dev/Prod/TestRole roles, mirroring project/bash/iam/res/roles.csv and the Bash implementation's `-r/--role` flag (opt-in, off by default)."
  type        = bool
  default     = false
}

variable "allowed_ips" {
  description = "Comma-separated-equivalent list of trusted CIDR ranges. When non-empty, an IPWhitelistPolicy Deny policy is created and attached to ProdGroup, mirroring iamctl's generate_ip_whitelist_policy. Empty list = no-op, matching Bash's behavior when ALLOWED_IPS is unset."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for cidr in var.allowed_ips : can(cidrhost(cidr, 0))])
    error_message = "Every entry in allowed_ips must be a valid CIDR block (e.g. \"203.0.113.10/32\")."
  }
}

variable "tags" {
  description = "Tags to apply to IAM resources that support tagging."
  type        = map(string)
  default     = {}
}
