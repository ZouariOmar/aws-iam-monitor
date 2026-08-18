# =========================================================
# modules/cloudwatch
#
# Lambda CloudWatch Log Group (Terraform-managed equivalent of
# lambda_ctl's imperative `create-log-group` + `put-retention-policy`
# calls) plus optional metric alarms on the Lambda-emitted
# AWSIAMMonitor metrics and standard Lambda errors. The alarms are
# a Terraform-only enhancement beyond the Bash implementation, which
# emits the metrics (see lambda_function.py: emit_metric,
# emit_unauthorized_ip_metric) but never creates alarms on them.
# =========================================================

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_cloudwatch_metric_alarm" "unauthorized_ip_access" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.lambda_function_name}-unauthorized-ip-access"
  alarm_description   = "Alerts when the monitoring Lambda blocks one or more IAM API calls from a source IP outside the configured whitelist."
  namespace           = "AWSIAMMonitor"
  metric_name         = "UnauthorizedIPAccess"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.lambda_function_name}-errors"
  alarm_description   = "Alerts when the monitoring Lambda function itself raises errors (execution failures, not IAM security findings)."
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  dimensions          = { FunctionName = var.lambda_function_name }
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}
