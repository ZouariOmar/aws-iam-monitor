locals {
  account_id = data.aws_caller_identity.current.account_id

  # Not exposed as variables — the Bash implementation hardcodes this exact
  # naming pattern (non-overridable) in cloud_trail_ctl / lambda_ctl, and
  # Terraform mirrors it exactly for name parity between the two
  # implementations.
  cloudtrail_bucket_name = "aws-cloudtrail-logs-${local.account_id}-${var.aws_region}"
  audit_bucket_name      = "aws-iam-monitor-history-${local.account_id}-${var.aws_region}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  # Matches project/bash/event-bridge/policies/iam-event-pattern.json
  # exactly: a broad filter on eventSource = iam.amazonaws.com. It is
  # NOT narrowed to a specific eventName list — the Bash implementation's
  # actual filtering by action (CreateUser, DeleteUser, CreateAccessKey,
  # etc.) happens inside the Lambda's MONITORED_ACTIONS dict, not at the
  # EventBridge layer, and Terraform intentionally preserves that split
  # rather than reinventing it here.
  iam_event_pattern = {
    source        = ["aws.iam"]
    "detail-type" = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["iam.amazonaws.com"]
    }
  }
}
