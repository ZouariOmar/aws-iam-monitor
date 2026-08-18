# aws-iam-monitor - Bash Implementation

- [aws-iam-monitor - Bash Implementation](#aws-iam-monitor-bash-implementation)
  - [Prerequisites and Setup](#prerequisites-%26-setup)
  - [Usage](#usage)
  - [Module Structure](#module-structure)
  - [Differences from the Terraform Implementation](#differences-from-the-terraform-implementation)

<div align="center">
<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/8/82/Gnu-bash-logo.svg/1280px-Gnu-bash-logo.svg.png" alt="bash logo">
</div>

The original **Bash/AWS-CLI** implementation of the **aws-iam-monitor** security
monitoring architecture, orchestrated by `./awsctl`. This is the primary,
imperative reference implementation; an equivalent, declarative
[Terraform implementation](../terraform/README.md) lives under `project/terraform/`.
Both are independently usable — see the root [README.md](../../README.md) for a
side-by-side comparison.

> [!WARNING]
> **Do not run both implementations against the same AWS account at the same
> time.** They use the same default resource names and would conflict.

## Prerequisites & Setup

See [`INSTALL.md`](../../INSTALL.md#bash-implementation) for tool requirements
and the `.env`/`chmod` setup steps — identical whether you got here from the
root README or directly.

## Usage

See [`USAGE.md`](../../USAGE.md#bash---awsctl) for the full `awsctl` command
reference (actions, targets, options) and deployment examples, or via the
dedicated Makefile: `make -C project/bash help`.

## Module Structure

```
project/bash/
├── awsctl                # Primary orchestration CLI
├── lib/                  # Shared helpers: common, logger, requirements
├── iam/                  # Policies, groups, users, optional roles + IP whitelist
├── cloud-trail/           # CloudTrail trail + its S3 log bucket
├── sns/                  # SNS alert topic + email subscription
├── lambda/                # Monitoring Lambda + execution role + S3 audit bucket
├── event-bridge/          # EventBridge rule + Lambda target + invoke permission
├── Makefile               # up/down/status/test wrapper around awsctl
├── .env.example            # Environment configuration template
└── README.md               # This file
```

## Differences from the Terraform Implementation

The Bash implementation is intentionally simpler/imperative in a few places
where the Terraform implementation adds declarative equivalents or tightens
scope — see [`project/terraform/README.md`](../terraform/README.md#differences-from-the-bash-implementation)
for the full comparison. In short: Bash's Lambda execution policy scopes
`S3AuditHistory`/`PublishAlerts` more broadly than Terraform's, Bash retries
Lambda creation with a sleep loop instead of a declarative wait, and Bash never
creates CloudWatch alarms (Terraform optionally does).
