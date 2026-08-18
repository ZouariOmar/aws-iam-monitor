# =========================================================
# modules/lambda
#
# Monitoring Lambda function, its execution role/policy, and code
# packaging. Mirrors project/bash/lambda/src/lambda_ctl and
# project/bash/lambda/policies/*.json, with two IAM statements
# intentionally tightened beyond the Bash implementation's wildcard
# scoping (see exec_policy below) — a deliberate least-privilege
# improvement, not a functional divergence.
#
# The function code is packaged directly from the existing Bash
# implementation's source file (var.lambda_source_file), so there is
# a single source of truth for the Lambda's security logic shared by
# both implementations.
# =========================================================

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = var.lambda_source_file
  output_path = "${path.module}/build/lambda_function.zip"
}

data "aws_iam_policy_document" "trust" {
  statement {
    sid    = "LambdaAssumeRole"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.trust.json
  tags               = var.tags
}

data "aws_iam_policy_document" "exec_policy" {
  statement {
    sid       = "CloudWatchLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
  }

  statement {
    sid       = "CloudWatchMetrics"
    effect    = "Allow"
    actions   = ["cloudwatch:PutMetricData"]
    resources = ["*"]
  }

  # Tightened vs. Bash's LambdaExecutionPolicy.json, which scopes this to
  # the wildcard-prefix "arn:aws:s3:::aws-iam-monitor-*/*" plus a vestigial
  # "arn:aws:s3:::iam-history/*" ARN from an earlier bucket-naming scheme.
  # Here it's scoped to exactly the audit bucket this function writes to.
  statement {
    sid       = "S3AuditHistory"
    effect    = "Allow"
    actions   = ["s3:PutObject", "s3:GetObject"]
    resources = ["${var.audit_bucket_arn}/*"]
  }

  # Tightened vs. Bash's LambdaExecutionPolicy.json, which scopes this to
  # "*". Here it's scoped to exactly the alert topic this function publishes to.
  statement {
    sid       = "PublishAlerts"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [var.sns_topic_arn]
  }
}

resource "aws_iam_policy" "lambda_exec" {
  name   = var.policy_name
  policy = data.aws_iam_policy_document.exec_policy.json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_exec" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_exec.arn
}

# IAM roles have eventual consistency — the Bash implementation retries
# `create-function` up to 6 times with a 10s sleep on "cannot be assumed"
# errors. This is the declarative equivalent: a short, deterministic pause
# between the role/policy attachment and the function referencing that role.
resource "time_sleep" "wait_for_role" {
  depends_on      = [aws_iam_role_policy_attachment.lambda_exec]
  create_duration = "10s"
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = var.runtime
  timeout       = var.timeout
  memory_size   = var.memory_size

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      AUDIT_BUCKET  = var.audit_bucket_name
      SNS_TOPIC_ARN = var.sns_topic_arn
      ALLOWED_IPS   = var.allowed_ips_raw
    }
  }

  tags = var.tags

  depends_on = [time_sleep.wait_for_role]
}
