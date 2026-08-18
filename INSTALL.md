# Installation

- [Installation](#installation)
  - [Clone Repository](#clone-repository)
  - [Requirements](#requirements)
    - [Bash implementation](#bash-implementation)
    - [Terraform implementation](#terraform-implementation)
    - [Documentation build (optional)](#documentation-build-optional)
  - [Setup](#setup)
    - [Bash](#bash)
    - [Terraform](#terraform)
    - [Docker](#docker)

**aws-iam-monitor** ships two independent, equivalent infrastructure
implementations, install prerequisites for whichever you plan to use (or
both). See [USAGE.md](USAGE.md) once installed, for the CLI reference of both.

## Clone Repository

```bash
git clone https://github.com/ZouariOmar/aws-iam-monitor.git
cd aws-iam-monitor
```

## Requirements

- Git
- AWS Account with access to:
  - CloudTrail
  - EventBridge
  - Lambda
  - STS AssumeRole
  - SNS
  - S3
  - CloudWatch
- Make (optional, but recommended, wraps both implementations)

### Bash implementation

- **Operating System**: Linux / macOS
- **Shell**: Bash v5.0+
- `aws-cli` (v2.0+)
- `jq` (v1.6+)
- `sed` (v4.10+)
- `zip` (v3.0+)
- `openssl` (v3.6+)
- `python3` (v3.11+)

### Terraform implementation

- Terraform >= 1.5.0
- The same AWS account access as above
- Network access to the Terraform Registry (`terraform init` downloads the
  `hashicorp/aws`, `hashicorp/archive`, and `hashicorp/time` providers
  automatically, no other local tooling required)

### Documentation build (optional)

- Python 3.14+ and `uv` (for the Sphinx `docapi` site, see `make docs`)

## Setup

### Bash

```bash
cd project/bash

# Configure environment variables (optional: SNS email, IP whitelist)
cp .env.example .env
nano .env   # SNS_ALERT_EMAIL=..., ALLOWED_IPS=1.2.3.4/32,5.6.7.8/24

# Ensure CLI executable permissions (or: make -C project/bash chmod)
chmod +x awsctl \
  lib/* \
  iam/src/* \
  cloud-trail/src/* \
  sns/src/* sns/test/* \
  event-bridge/src/* event-bridge/test/* \
  lambda/src/* lambda/test/*

# Verify AWS CLI authentication
aws sts get-caller-identity
```

### Terraform

```bash
cd project/terraform
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars   # sns_alert_email, allowed_ips, etc.
terraform init
```

See [`project/terraform/README.md`](project/terraform/README.md) for the full
reference.

### Docker

Each implementation has its own Dockerfile (`project/bash/Dockerfile`,
`project/terraform/Dockerfile`) and its own set of Makefile targets, prefixed
`bash-docker-*` and `tr-docker-*` respectively:

```bash
make bash-docker  # build + run + open a shell (Bash implementation)
make tr-docker    # build + run + open a shell (Terraform implementation)
```

Once installed, see [USAGE.md](USAGE.md) for how to run either
implementation.
