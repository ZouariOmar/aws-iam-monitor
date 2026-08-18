# =========================================================
# modules/cloudtrail
#
# CloudTrail trail + the bucket policy required for CloudTrail
# to write into the S3 log bucket created by a separate `s3`
# module instance (passed in via var.s3_bucket_*). Mirrors
# project/bash/cloud-trail/src/cloud_trail_ctl and
# project/bash/cloud-trail/policies/{bucket-policy,event-selectors}.json
# exactly.
# =========================================================

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [var.s3_bucket_arn]
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${var.s3_bucket_arn}/AWSLogs/${var.account_id}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = var.s3_bucket_id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

resource "aws_cloudtrail" "this" {
  name           = var.trail_name
  s3_bucket_name = var.s3_bucket_name

  # is_multi_region_trail intentionally left unset (AWS provider default:
  # false) — the Bash implementation calls `aws cloudtrail create-trail`
  # without --is-multi-region-trail, i.e. single-region, and Terraform
  # mirrors that behavior exactly rather than silently broadening it.

  event_selector {
    read_write_type           = var.read_write_type
    include_management_events = true
  }

  tags = var.tags

  depends_on = [aws_s3_bucket_policy.this]
}
