# No credentials are configured here — the AWS provider uses the standard
# credential resolution chain (environment variables, shared config/
# credentials file, SSO profile, or an attached IAM role), exactly like the
# Bash implementation relies on whatever `aws sts get-caller-identity`
# resolves to. Never hardcode access keys in this file or in *.tfvars.
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}
