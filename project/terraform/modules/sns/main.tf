# =========================================================
# modules/sns
#
# Security alert SNS topic, topic policy, and optional email
# subscription. Mirrors project/bash/sns/src/sns_ctl and
# project/bash/sns/policies/sns-topic-policy.json exactly.
# =========================================================

resource "aws_sns_topic" "this" {
  name = var.topic_name
  tags = var.tags
}

data "aws_iam_policy_document" "topic_policy" {
  statement {
    sid    = "__default_statement_ID"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "SNS:GetTopicAttributes",
      "SNS:SetTopicAttributes",
      "SNS:AddPermission",
      "SNS:RemovePermission",
      "SNS:DeleteTopic",
      "SNS:Subscribe",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish",
    ]

    resources = [aws_sns_topic.this.arn]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values   = [var.account_id]
    }
  }

  statement {
    sid    = "AWSIAMMonitorSNSPublish"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "cloudwatch.amazonaws.com"]
    }

    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.this.arn]
  }
}

resource "aws_sns_topic_policy" "this" {
  arn    = aws_sns_topic.this.arn
  policy = data.aws_iam_policy_document.topic_policy.json
}

# Optional email subscription — created only when var.alert_email is set,
# mirroring sns_ctl's `if [[ -n "$ALERT_EMAIL" ]]` behavior. AWS sends a
# confirmation email; the subscription stays PendingConfirmation until the
# recipient clicks the link, exactly as under the Bash implementation.
resource "aws_sns_topic_subscription" "email" {
  count = var.alert_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
