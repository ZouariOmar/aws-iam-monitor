# =========================================================
# modules/eventbridge
#
# EventBridge rule filtering CloudTrail IAM API calls, its Lambda
# target, and the permission allowing EventBridge to invoke that
# Lambda. Mirrors project/bash/event-bridge/src/event_bridge_ctl
# and project/bash/event-bridge/policies/iam-event-pattern.json
# exactly — notably, the pattern filters broadly on
# eventSource = iam.amazonaws.com rather than a specific list of
# eventNames; the actual MONITORED_ACTIONS allow-list filtering
# happens inside the Lambda's Python code, not at the EventBridge
# layer, and Terraform intentionally preserves that split.
# =========================================================

resource "aws_cloudwatch_event_rule" "this" {
  name          = var.rule_name
  event_pattern = jsonencode(var.event_pattern)
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.this.name
  target_id = "Target1"
  arn       = var.lambda_function_arn
}

resource "aws_lambda_permission" "eventbridge_invoke" {
  statement_id  = "eventbridge-invoke-${var.rule_name}"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
}
