# aws-iam-monitor - Terraform Implementation

- [aws-iam-monitor - Terraform Implementation](#aws-iam-monitor---terraform-implementation)
  - [Module Structure](#module-structure)
  - [Prerequisites & Setup](#prerequisites--setup)
  - [AWS Authentication](#aws-authentication)
  - [Usage](#usage)
  - [Variable Configuration](#variable-configuration)
  - [Operational Notes](#operational-notes)
  - [Terraform State Security](#terraform-state-security)
  - [Differences from the Bash Implementation](#differences-from-the-bash-implementation)
  - [Equivalence Statement](#equivalence-statement)

<div align="center">
<img src="https://s3-ap-southeast-2.amazonaws.com/content-prod-529546285894/2020/03/tf.png" alt="terraform logo">
</div>

A declarative, Infrastructure-as-Code implementation of the **aws-iam-monitor**
security monitoring architecture, equivalent to the [Bash implementation](../bash/README.md)
under `project/bash/`. This is **not** a replacement for the Bash implementation;
both are independently usable and provision the same core architecture, see
[`ARCHITECTURE.md`](../../ARCHITECTURE.md) for the diagram and AWS services table.

> [!WARNING]
> **Do not run both implementations against the same AWS account at the same
> time.** Both use the same default resource names (`aws-iam-monitor-lambda`,
> `iam-alerts`, `aws-iam-monitor-rule`, etc.), so applying both would attempt to
> create identically-named resources and conflict. Pick one per account, or
> change one implementation's variable/`.env` overrides to use distinct names.

## Module Structure

```
project/terraform/
├── main.tf                    # data sources + module wiring
├── variables.tf                # root input variables
├── outputs.tf                  # the 9 required outputs
├── providers.tf                # AWS provider configuration
├── versions.tf                 # Terraform & provider version constraints
├── locals.tf                   # computed values (bucket names, tags, event pattern)
├── terraform.tfvars.example    # copy to terraform.tfvars and edit
├── Makefile                    # init/fmt/validate/plan/apply/destroy wrapper
└── modules/
    ├── s3/            # generic bucket: encryption, versioning, public-access block
    │                  #   (instantiated twice: CloudTrail logs + audit history)
    ├── cloudtrail/     # trail + its S3 bucket policy
    ├── iam/            # demo sandbox policies/groups/users/roles + IP whitelist
    ├── sns/            # alert topic, topic policy, optional email subscription
    ├── cloudwatch/     # Lambda log group + optional metric alarms
    ├── lambda/         # monitoring function, execution role/policy, packaging
    └── eventbridge/    # rule, Lambda target, invoke permission
```

| Module        | Responsibility                                                                                                                                            |
| ------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `s3`          | Generic, reusable bucket (encryption, versioning, public-access block). No bucket policy, that's owned by the caller.                                     |
| `cloudtrail`  | CloudTrail trail + the CloudTrail-specific bucket policy on the `s3` module's CloudTrail-logs instance.                                                   |
| `iam`         | Demo IAM sandbox (policies, groups, users, optional roles) and the dynamically-generated IP whitelist policy. Self-contained, no cross-module references. |
| `sns`         | Security alert topic, topic policy, optional email subscription.                                                                                          |
| `cloudwatch`  | Lambda CloudWatch Log Group + optional metric alarms (enhancement beyond Bash).                                                                           |
| `lambda`      | Monitoring function, its execution role/policy, and code packaging from the shared Python source.                                                         |
| `eventbridge` | Rule filtering CloudTrail IAM events, Lambda target, invoke permission.                                                                                   |

## Prerequisites & Setup

See [`INSTALL.md`](../../INSTALL.md#terraform-implementation) for tool
requirements and the `terraform.tfvars`/`terraform init` setup steps,
identical whether you got here from the root README or directly.

## AWS Authentication

Terraform does **not** read `project/bash/.env`, configuration is entirely
variable-driven via `terraform.tfvars`. AWS credentials are resolved by the AWS
provider's standard credential chain, exactly like the Bash implementation relies
on whatever `aws sts get-caller-identity` resolves to:

- Environment variables (`AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` / `AWS_SESSION_TOKEN`)
- A shared credentials/config file (`~/.aws/credentials`, `AWS_PROFILE`)
- An assumed IAM role / SSO profile
- An attached IAM role (EC2 instance profile, CodeBuild, CI runner, etc.)

Never hardcode credentials in `.tf` files or `terraform.tfvars`.

## Usage

See [`USAGE.md`](../../USAGE.md#terraform) for the full command reference
(`init`/`plan`/`apply`/`destroy`) and deployment examples, or via the
dedicated Makefile: `make -C project/terraform help`.

## Variable Configuration

All variables have defaults matching the Bash implementation's `.env.example` and
each `*_ctl` script's hardcoded defaults, so a plain `terraform apply` with no
overrides is equivalent to `./awsctl --up all` (including the demo IAM sandbox).

| Variable                          | Type         | Default                             | Bash equivalent                                  |
| --------------------------------- | ------------ | ----------------------------------- | ------------------------------------------------ |
| `aws_region`                      | string       | `us-east-1`                         | `AWS_REGION`                                     |
| `project_name`                    | string       | `aws-iam-monitor`                   | , (tagging only)                                 |
| `environment`                     | string       | `production`                        | , (tagging only)                                 |
| `enable_iam_sandbox`              | bool         | `true`                              | `./awsctl --up all` (always creates the sandbox) |
| `enable_iam_roles`                | bool         | `false`                             | `-r` / `--role` flag (opt-in)                    |
| `allowed_ips`                     | list(string) | `[]`                                | `ALLOWED_IPS`                                    |
| `sns_topic_name`                  | string       | `iam-alerts`                        | `SNS_TOPIC_NAME`                                 |
| `sns_alert_email`                 | string       | `""`                                | `SNS_ALERT_EMAIL`                                |
| `trail_name`                      | string       | `aws-iam-monitor-management-events` | `TRAIL_NAME`                                     |
| `trail_read_write_type`           | string       | `All`                               | `--event-selectors-rw-type`                      |
| `bucket_encryption_sse_algorithm` | string       | `AES256`                            | `--bucket-encryption-sse-algorithm`              |
| `lambda_function_name`            | string       | `aws-iam-monitor-lambda`            | `LAMBDA_FUNCTION_NAME`                           |
| `lambda_role_name`                | string       | `aws-iam-monitor-lambda-role`       | `LAMBDA_ROLE_NAME`                               |
| `lambda_policy_name`              | string       | `LambdaExecutionPolicy`             | `--policy-name`                                  |
| `lambda_runtime`                  | string       | `python3.11`                        | `LAMBDA_RUNTIME` (hardcoded in Bash)             |
| `lambda_timeout`                  | number       | `15`                                | hardcoded `--timeout 15`                         |
| `lambda_memory_size`              | number       | `128`                               | AWS default (Bash never sets this)               |
| `log_retention_days`              | number       | `30`                                | hardcoded `--retention-in-days 30`               |
| `eventbridge_rule_name`           | string       | `aws-iam-monitor-rule`              | `RULE_NAME`                                      |
| `enable_cloudwatch_alarms`        | bool         | `true`                              | , (Terraform-only enhancement)                   |

## Operational Notes

- `terraform plan` calls **read-only** AWS APIs (to check existing state) using
  whatever credentials are active, review the plan output carefully,
  especially against a real/shared AWS account.
- `terraform apply -auto-approve` skips the interactive confirmation prompt,
  only use it in CI/automation where you already trust the plan
  (`make apply-auto` / `make destroy-auto` wrap this, clearly labeled as
  dangerous).
- Changing the shared Lambda source
  (`project/bash/lambda/src/lambda_function.py`) is detected automatically via
  `source_code_hash` and redeployed on the next `apply`, no manual packaging
  step needed.
- `terraform destroy` removes everything, including bucket contents: S3
  buckets are created with `force_destroy = true` so `destroy` can remove them
  even if they still contain objects (audit logs, CloudTrail logs), mirroring
  the Bash implementation's `aws s3 rm --recursive` teardown step. Set
  `force_destroy = false` on the relevant `s3` module call in `main.tf` if you
  want buckets to block accidental deletion instead.

## Terraform State Security

- **No secrets are stored in state**, no passwords, access keys, or login
  profiles are ever created by this configuration (matching the Bash
  implementation, which also never creates IAM credentials). State does contain
  resource ARNs, IDs, and the full rendered IAM policy documents.
- The default backend is **local state** (`terraform.tfstate` in this directory,
  gitignored), fine for solo experimentation, but **not safe for team or
  production use**: it's single-user, has no locking, and is easy to lose.
- For any shared/real deployment, configure a **remote backend** instead, e.g.:

  ```hcl
  # backend.tf (not included by default,  add this yourself)
  terraform {
    backend "s3" {
      bucket         = "your-terraform-state-bucket"
      key            = "aws-iam-monitor/terraform.tfstate"
      region         = "us-east-1"
      dynamodb_table = "your-terraform-locks-table" # state locking
      encrypt        = true
    }
  }
  ```

  Terraform Cloud/HCP Terraform is another good option with built-in locking,
  encryption, and access control.

## Differences from the Bash Implementation

Both implementations are _behaviorally equivalent_ (same resources, same
defaults, same event filtering), with these deliberate Terraform-side
improvements/differences:

| Area                                               | Bash                                                                                 | Terraform                                                                                                                         |
| -------------------------------------------------- | ------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------- |
| Lambda `S3AuditHistory` IAM statement              | `arn:aws:s3:::aws-iam-monitor-*/*` + vestigial `arn:aws:s3:::iam-history/*`          | Scoped to exactly `${audit_bucket_arn}/*` (tighter least-privilege)                                                               |
| Lambda `PublishAlerts` IAM statement               | `Resource: "*"`                                                                      | Scoped to exactly the SNS topic ARN (tighter least-privilege)                                                                     |
| `AwsIamMonitorLambdaRole` (4th row of `roles.csv`) | Created only when `--role` is passed (redundant with the always-created Lambda role) | Not reproduced, deduplicated, since it's redundant with the Lambda execution role                                                 |
| S3 public access                                   | Not explicitly blocked                                                               | `aws_s3_bucket_public_access_block` on both buckets (all 4 flags true)                                                            |
| Lambda IAM propagation wait                        | 6× retry loop with 10s sleep on "cannot be assumed"                                  | Single deterministic `time_sleep` (10s) before the function references the role                                                   |
| Lambda code deploy                                 | Manual SHA-256 compare-and-update                                                    | `source_code_hash`, automatic, declarative                                                                                        |
| CloudWatch Log Group                               | Created imperatively after the function exists                                       | Created first, Terraform-managed, explicit dependency                                                                             |
| CloudWatch alarms                                  | None (metrics are emitted but never alarmed on)                                      | Optional (`enable_cloudwatch_alarms`, default on): `UnauthorizedIPAccess` and Lambda `Errors` alarms, publishing to the SNS topic |
| `lambda_memory_size`                               | Relies on AWS default (128MB, implicit)                                              | Explicit variable, default 128MB                                                                                                  |

Everything else, resource naming, the EventBridge event pattern (broad
`iam.amazonaws.com` filter; the actual `MONITORED_ACTIONS` allow-list filtering
still happens inside the Lambda's Python code, in both implementations), IAM
policy documents (`DevPolicy`/`ProdPolicy`/`AuditPolicy`/`IPWhitelistPolicy`),
SNS topic policy, CloudTrail bucket policy, and default resource names, is
intentionally identical between the two implementations.

## Equivalence Statement

Both implementations provision the same core AWS security monitoring
architecture, IAM sandbox, CloudTrail, SNS, Lambda, EventBridge, S3, and
CloudWatch, with the same default resource names when using default
configuration values. Either can be used standalone; see
[`project/bash/README.md`](../bash/README.md) for the Bash CLI reference.
