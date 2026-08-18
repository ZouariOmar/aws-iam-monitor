# Implement Equivalent Terraform Infrastructure

## Description

Add a complete **Terraform-based implementation** of the `aws-iam-monitor` infrastructure.

The existing project is a **Bash/AWS CLI implementation** and must remain fully supported. Its existing files should be organized under `project/bash/`.

Terraform will be added as a **second, equivalent infrastructure implementation** under `project/terraform/`.

This is **not a migration or replacement** of the existing Bash implementation.

The final project should support two independent deployment approaches:

- **Bash** — existing AWS CLI/Bash implementation.
- **Terraform** — new declarative Infrastructure as Code implementation.

## Target Project Structure

    project/
    ├── bash/
    │   ├── awsctl
    │   ├── lib/
    │   ├── iam/
    │   ├── cloud-trail/
    │   ├── sns/
    │   ├── event-bridge/
    │   └── lambda/
    │
    └── terraform/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        ├── providers.tf
        ├── versions.tf
        ├── locals.tf
        ├── terraform.tfvars.example
        ├── modules/
        │   ├── iam/
        │   ├── cloudtrail/
        │   ├── sns/
        │   ├── lambda/
        │   ├── eventbridge/
        │   ├── s3/
        │   └── cloudwatch/
        └── README.md

The exact Terraform module structure may be adjusted if a cleaner architecture is identified.

## Objectives

- [ ] Move the existing Bash implementation into `project/bash/`.
- [ ] Preserve the existing Bash functionality after the move.
- [ ] Keep `awsctl` as the primary Bash orchestration CLI.
- [ ] Add Terraform under `project/terraform/`.
- [ ] Provision an equivalent AWS security monitoring architecture using Terraform.
- [ ] Use reusable and maintainable Terraform modules.
- [ ] Preserve existing security and least-privilege requirements.
- [ ] Make Terraform configuration environment-driven through variables.
- [ ] Ensure Terraform infrastructure is idempotent.
- [ ] Document both deployment approaches (/_.md & docapi/_).
- [ ] Keep resource naming and configuration conventions consistent between implementations where practical.
- [ ] Update the root `Makefile` to support both deployment implementations.
- [ ] Add a dedicated `Makefile` under `project/bash/`.
- [ ] Add a dedicated `Makefile` under `project/terraform/`.
- [ ] Ensure the root `Makefile` delegates Bash and Terraform commands to their respective sub-Makefiles.
- [ ] Keep Bash and Terraform workflows independently usable through their own Makefiles.

## Bash Implementation

The existing Bash implementation should be reorganized without changing its behavior.

Move the current components into:

    project/bash/
    ├── awsctl
    ├── lib/
    ├── iam/
    ├── cloud-trail/
    ├── sns/
    ├── event-bridge/
    └── lambda/

After the reorganization, the following commands should continue to work:

    cd project/bash

    ./awsctl --up all
    ./awsctl --status all
    ./awsctl --test all
    ./awsctl --down all

Any required path references inside the Bash scripts must be updated accordingly.

## Terraform Implementation

Terraform should independently provision the same core AWS architecture currently managed by the Bash implementation.

### AWS Resources

Terraform should cover, at minimum:

- [ ] IAM users, groups, policies, and roles.
- [ ] CloudTrail trail.
- [ ] CloudTrail logging S3 bucket.
- [ ] SNS security alert topic.
- [ ] Optional SNS email subscription.
- [ ] Lambda monitoring function.
- [ ] Lambda execution IAM role and policies.
- [ ] S3 bucket for IAM audit history.
- [ ] EventBridge IAM event rule.
- [ ] EventBridge → Lambda target.
- [ ] Lambda invocation permission for EventBridge.
- [ ] CloudWatch log group.
- [ ] CloudWatch metrics and alarms where applicable.
- [ ] S3 encryption and versioning.
- [ ] IP whitelist configuration and associated IAM policy.

## Configuration

Terraform should provide variables corresponding to relevant existing project configuration.

Example:

```terraform
aws_region      = "us-east-1"
sns_alert_email = "security-team@example.com"
allowed_ips     = ["1.2.3.4/32", "5.6.7.8/24"]
environment     = "production"
project_name    = "aws-iam-monitor
```

Provide:

```bash
project/terraform/terraform.tfvars.example
```

No credentials, secrets, or sensitive values should be committed.

Terraform state files must be excluded from Git.

## Lambda

Terraform should integrate with the existing Python Lambda implementation.

- [ ] Automatically package the Lambda source.
- [ ] Detect Lambda source changes and deploy updates.
- [ ] Use Python 3.11+.
- [ ] Configure required Lambda environment variables.
- [ ] Avoid unnecessary runtime dependencies.
- [ ] Preserve equivalent Lambda functionality.

Terraform should avoid unnecessarily duplicating or changing the application's security logic.

## EventBridge

Create an EventBridge rule for sensitive IAM operations captured through CloudTrail.

The implementation should preserve the existing monitoring behavior, including operations such as:

- `CreateUser`
- `DeleteUser`
- `CreateAccessKey`
- `CreateLoginProfile`
- `DeactivateMFADevice`
- `AttachUserPolicy`
- `AttachRolePolicy`
- `PutUserPolicy`
- `PutRolePolicy`
- `DeletePolicy`

The final event pattern should be based on the existing implementation.

## Security Requirements

- [ ] Follow AWS least-privilege principles.
- [ ] Do not hardcode AWS credentials.
- [ ] Do not commit Terraform state.
- [ ] Enable S3 server-side encryption.
- [ ] Enable S3 versioning where appropriate.
- [ ] Restrict S3 bucket access.
- [ ] Use dedicated IAM roles for Lambda and AWS services.
- [ ] Avoid unnecessary wildcard permissions.
- [ ] Restrict SNS topic policies appropriately.
- [ ] Protect CloudTrail logs from unauthorized modification.
- [ ] Preserve existing IP whitelist/security behavior.
- [ ] Document Terraform state security and remote-state recommendations.

## Outputs

Expose useful infrastructure values through Terraform outputs:

```text
cloudtrail_name
cloudtrail_bucket_name
audit_bucket_name
sns_topic_arn
lambda_function_name
lambda_function_arn
eventbridge_rule_name
eventbridge_rule_arn
lambda_role_arn
```

## Validation & Testing

Terraform must support:

```bash
cd project/terraform

terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
```

Verify end-to-end that:

- [ ] CloudTrail captures IAM management events.
- [ ] EventBridge receives matching events.
- [ ] EventBridge invokes Lambda.
- [ ] Lambda classifies IAM events.
- [ ] High-risk events are published to SNS.
- [ ] IAM audit events are stored in S3.
- [ ] CloudWatch logs and metrics are generated.
- [ ] IP whitelist enforcement works as expected.
- [ ] Terraform is idempotent.
- [ ] A second `terraform plan` shows no unexpected changes.

## Documentation

Add:

```bash
project/terraform/README.md
project/bash/README.md
```

Document:

- [ ] Terraform prerequisites.
- [ ] AWS authentication.
- [ ] Terraform initialization.
- [ ] Variable configuration.
- [ ] `terraform plan`.
- [ ] `terraform apply`.
- [ ] Updating infrastructure.
- [ ] `terraform destroy`.
- [ ] Terraform state security.
- [ ] Terraform module structure.
- [ ] Differences between Bash and Terraform.
- [ ] How both implementations provide equivalent infrastructure.

Update the root README & docpai with a Terraform deployment section.

Example:

```bash
# Bash implementation
cd project/bash
./awsctl --up all

# Terraform implementation
cd project/terraform
terraform init
terraform plan
terraform apply
```

## Acceptance Criteria

- [ ] Existing Bash implementation is organized under `project/bash/`.
- [ ] Existing `awsctl` functionality continues to work after the reorganization.
- [ ] Terraform implementation exists under `project/terraform/`.
- [ ] Terraform can independently provision the monitoring infrastructure.
- [ ] Terraform provides an equivalent AWS monitoring architecture.
- [ ] Terraform is idempotent.
- [ ] A second `terraform plan` shows no unexpected changes.
- [ ] IAM permissions follow least-privilege principles.
- [ ] CloudTrail, EventBridge, Lambda, SNS, S3, and CloudWatch work end-to-end.
- [ ] Existing security monitoring functionality remains intact.
- [ ] No credentials or sensitive Terraform state are committed.
- [ ] Terraform passes formatting and validation.
- [ ] Documentation covers both deployment approaches.
- [ ] Bash and Terraform implementations remain independently usable.
