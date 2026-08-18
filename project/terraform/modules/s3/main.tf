# =========================================================
# modules/s3
#
# Generic, reusable S3 bucket: default encryption, versioning,
# and a public-access block. Instantiated twice by the root
# module — once for the CloudTrail log bucket, once for the
# Lambda audit history bucket. Service-specific bucket policies
# (e.g. the CloudTrail bucket policy) are owned by the calling
# module (see modules/cloudtrail), not by this generic module.
# =========================================================

resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_algorithm
      kms_master_key_id = var.sse_algorithm == "aws:kms" ? var.kms_key_id : null
    }
  }
}

# Restrict bucket access — additive hardening beyond the Bash implementation
# (which does not set a public access block), per the issue's "restrict S3
# bucket access" security requirement.
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
