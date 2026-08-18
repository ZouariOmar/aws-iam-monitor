terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.11"
    }
  }

  # No backend is configured here — the default is local state
  # (terraform.tfstate in this directory, gitignored). For team or
  # production use, configure a remote backend (e.g. S3 + DynamoDB
  # locking) instead. See README.md's "Terraform State Security"
  # section for details and an example backend block.
}
