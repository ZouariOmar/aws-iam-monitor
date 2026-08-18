# =========================================================
# aws-iam-monitor — Terraform root module
#
# Wires together the reusable modules under modules/ into the same
# end-to-end AWS security monitoring architecture provisioned by
# the Bash implementation (project/bash/awsctl --up all). All
# resources are declared inside modules — this file only contains
# data sources and module wiring.
#
# Dependency graph:
#
#   s3 (cloudtrail_logs) --> cloudtrail
#   iam                                              (independent branch,
#                                                      no cross-module refs)
#   s3 (audit) --\
#   sns ----------+--> cloudwatch --> lambda --> eventbridge
#
# `iam` and `cloudtrail` are never wired to the Lambda/EventBridge
# branch — matching Bash, where IAM and CloudTrail are independently
# staged and never cross-referenced by ARN.
# =========================================================

data "aws_caller_identity" "current" {}

# ---------------------------------------------------------------------------
# IAM branch
# ---------------------------------------------------------------------------

module "iam" {
  source = "./modules/iam"

  account_id         = local.account_id
  enable_iam_sandbox = var.enable_iam_sandbox
  enable_iam_roles   = var.enable_iam_roles
  allowed_ips        = var.allowed_ips
  tags               = local.common_tags
}

# ---------------------------------------------------------------------------
# CloudTrail branch
# ---------------------------------------------------------------------------

module "s3_cloudtrail" {
  source = "./modules/s3"

  bucket_name       = local.cloudtrail_bucket_name
  sse_algorithm     = var.bucket_encryption_sse_algorithm
  enable_versioning = true
  tags              = local.common_tags
}

module "cloudtrail" {
  source = "./modules/cloudtrail"

  trail_name      = var.trail_name
  s3_bucket_id    = module.s3_cloudtrail.bucket_id
  s3_bucket_name  = module.s3_cloudtrail.bucket_name
  s3_bucket_arn   = module.s3_cloudtrail.bucket_arn
  account_id      = local.account_id
  read_write_type = var.trail_read_write_type
  tags            = local.common_tags
}

# ---------------------------------------------------------------------------
# Monitoring pipeline branch: S3 audit bucket + SNS -> CloudWatch -> Lambda
# -> EventBridge
# ---------------------------------------------------------------------------

module "s3_audit" {
  source = "./modules/s3"

  bucket_name       = local.audit_bucket_name
  sse_algorithm     = var.bucket_encryption_sse_algorithm
  enable_versioning = true
  tags              = local.common_tags
}

module "sns" {
  source = "./modules/sns"

  topic_name  = var.sns_topic_name
  alert_email = var.sns_alert_email
  account_id  = local.account_id
  aws_region  = var.aws_region
  tags        = local.common_tags
}

module "cloudwatch" {
  source = "./modules/cloudwatch"

  lambda_function_name     = var.lambda_function_name
  log_retention_days       = var.log_retention_days
  enable_cloudwatch_alarms = var.enable_cloudwatch_alarms
  sns_topic_arn            = module.sns.topic_arn
  tags                     = local.common_tags
}

module "lambda" {
  source = "./modules/lambda"

  function_name      = var.lambda_function_name
  role_name          = var.lambda_role_name
  policy_name        = var.lambda_policy_name
  runtime            = var.lambda_runtime
  timeout            = var.lambda_timeout
  memory_size        = var.lambda_memory_size
  lambda_source_file = "${path.module}/../bash/lambda/src/lambda_function.py"
  audit_bucket_name  = module.s3_audit.bucket_name
  audit_bucket_arn   = module.s3_audit.bucket_arn
  sns_topic_arn      = module.sns.topic_arn
  allowed_ips_raw    = join(",", var.allowed_ips)
  tags               = local.common_tags

  # The function's environment variables don't reference the log group
  # directly, so there's no implicit dependency — force it explicitly so
  # the log group (and its retention policy) exists before the function
  # starts logging.
  depends_on = [module.cloudwatch]
}

module "eventbridge" {
  source = "./modules/eventbridge"

  rule_name            = var.eventbridge_rule_name
  event_pattern        = local.iam_event_pattern
  lambda_function_arn  = module.lambda.function_arn
  lambda_function_name = module.lambda.function_name
}
