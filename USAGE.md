# Usage

- [Usage](#usage)
  - [Makefile](#makefile)
    - [Main](#main)
    - [Bash Implementation](#bash-implementation)
    - [Terraform Implementation](#terraform-implementation)
    - [Documentation](#documentation)
    - [Docker](#docker)
  - [Bash - `awsctl`](#bash---awsctl)
    - [Command Syntax](#command-syntax)
    - [Actions](#actions)
    - [Targets](#targets)
    - [Options](#options)
    - [Deployment Examples](#deployment-examples)
  - [Terraform](#terraform)
    - [Command Syntax](#command-syntax-1)
    - [Deployment Examples](#deployment-examples-1)

**aws-iam-monitor** ships two independent, equivalent infrastructure
implementations, pick whichever fits your workflow. Do not run both against
the same AWS account simultaneously; they use the same default resource names
and would conflict.

> [!IMPORTANT]
> See [INSTALL.md](INSTALL.md) if you haven't set up prerequisites yet.

## Makefile

The root `Makefile` delegates Bash- and Terraform-specific commands to their
own sub-Makefiles (`project/bash/Makefile`, `project/terraform/Makefile`),
which remain independently usable via `make -C project/bash <target>` /
`make -C project/terraform <target>`.

> [!NOTE]
> Run `make help` at any level for the full, self-documenting list.

### Main

| Target            | Description                                                  |
| :---------------- | :----------------------------------------------------------- |
| `make init`       | Init the project (`uv venv`)                                 |
| `make sync`       | Sync dependencies (`uv sync`)                                |
| `make run`        | Run the Bash implementation (`ARGS=...`)                     |
| `make test`       | Run the Bash implementation's tests                          |
| `make clean`      | Clean the project                                            |
| `make changelog`  | Generate `CHANGELOG.md`                                      |
| `make version-up` | Bump project version and create a git tag                    |
| `make gh-issue`   | Create a GitHub issue from a template (`TITLE=... FILE=...`) |

### Bash Implementation

| Target                        | Description                                        |
| :---------------------------- | :------------------------------------------------- |
| `make bash-up TARGET=...`     | Provision infrastructure (`TARGET` default: `all`) |
| `make bash-down TARGET=...`   | Tear down infrastructure                           |
| `make bash-status TARGET=...` | Show infrastructure status                         |
| `make bash-test TARGET=...`   | Run the Bash test suite                            |

### Terraform Implementation

| Target             | Description          |
| :----------------- | :------------------- |
| `make tf-init`     | `terraform init`     |
| `make tf-fmt`      | `terraform fmt`      |
| `make tf-validate` | `terraform validate` |
| `make tf-plan`     | `terraform plan`     |
| `make tf-apply`    | `terraform apply`    |
| `make tf-destroy`  | `terraform destroy`  |
| `make tf-output`   | `terraform output`   |

### Documentation

| Target              | Description                     |
| :------------------ | :------------------------------ |
| `make docs`         | Build the Sphinx docs to HTML   |
| `make docs-serve`   | Serve the built docs locally    |
| `make docs-preview` | Build and preview docs (Vercel) |
| `make docs-deploy`  | Build and deploy docs (Vercel)  |

### Docker

Each implementation builds and runs from its own Dockerfile
(`project/bash/Dockerfile`, `project/terraform/Dockerfile`), via its own
prefixed set of targets:

| Target                    | Description                                     |
| :------------------------ | :----------------------------------------------- |
| `make bash-docker`        | Build + run + open a shell (Bash)               |
| `make bash-docker-build`  | Build the Bash Docker image                     |
| `make bash-docker-bash`   | Open a shell inside the Bash container          |
| `make bash-docker-run`    | Run `awsctl` inside the Bash container          |
| `make bash-docker-stop`   | Stop the running Bash container                 |
| `make bash-docker-clean`  | Remove the Bash Docker image                    |
| `make tr-docker`          | Build + run + open a shell (Terraform)          |
| `make tr-docker-build`    | Build the Terraform Docker image                |
| `make tr-docker-bash`     | Open a shell inside the Terraform container     |
| `make tr-docker-run`      | Run `terraform` inside the Terraform container  |
| `make tr-docker-stop`     | Stop the running Terraform container            |
| `make tr-docker-clean`    | Remove the Terraform Docker image               |

## Bash - `awsctl`

The primary orchestration tool is `./awsctl`, run from `project/bash/`. It
provides a unified command line interface for provisioning, managing,
testing, and destroying infrastructure components.

### Command Syntax

```bash
cd project/bash
./awsctl <ACTION> [TARGET] [OPTIONS]
```

### Actions

- `--up` : Create/configure resources.
- `--down` : Tear down/delete resources.
- `--status` : Check status of resources.
- `--test` : Execute test suites.

### Targets

- `all` _(default)_ : Complete monitoring infrastructure.
- `iam` : IAM policies, groups, users, and roles.
- `cloud-trail` : CloudTrail trail and log S3 bucket.
- `sns` : SNS security alert topic and email subscriptions.
- `lambda` : Lambda function and audit S3 bucket.
- `event-bridge` : EventBridge rule and target registration.

### Options

- `-r`, `--role` : Include optional IAM roles during IAM setup.
- `-v`, `--verbose` : Display detailed AWS CLI execution logs.
- `-h`, `--help` : Show help message.

### Deployment Examples

```bash
./awsctl --up all          # Provision the complete monitoring pipeline
```

_This will automatically:_

1. Create customer-managed IAM policies (`DevPolicy`, `ProdPolicy`, `AuditPolicy`), groups (`DevGroup`, `ProdGroup`, `TestGroup`), and users (`DevAdmin`, `ProdAdmin`, etc.).
2. Provision an S3 log bucket and create a CloudTrail management events trail.
3. Provision the SNS alert topic (`iam-alerts`) and subscribe `SNS_ALERT_EMAIL` if configured in `.env`.
4. Provision an S3 audit history bucket and deploy the monitoring Lambda function with its execution role.
5. Create an EventBridge rule for IAM events, attach the Lambda function as a target, and grant invocation permissions.

```bash
./awsctl --up sns          # Provision only the SNS alert component
./awsctl --status all      # Check status of every component
./awsctl --test all        # Run automated test suites
./awsctl --down all        # Tear down the complete infrastructure
```

> [!NOTE]
> For prerequisites, setup, module structure, and a detailed comparison
> against the Terraform implementation, see [`Bash - README.md`](project/bash/README.md).

## Terraform

The equivalent declarative implementation lives under `project/terraform/`.

### Command Syntax

```bash
cd project/terraform
terraform init
terraform plan
terraform apply
terraform destroy
```

A plain `terraform apply` with default variables provisions the same
architecture as `./awsctl --up all`, including the demo IAM sandbox
(`enable_iam_sandbox = true` by default). Configuration is entirely
variable-driven via `terraform.tfvars` (copy from `terraform.tfvars.example`)
— Terraform does not read the Bash implementation's `.env` file.

### Deployment Examples

```bash
# First-time provisioning
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply

# Updating infrastructure, edit terraform.tfvars, then:
terraform plan
terraform apply

# Teardown
terraform destroy
```

Changing the shared Lambda source
(`project/bash/lambda/src/lambda_function.py`) is detected automatically via
`source_code_hash` and redeployed on the next `apply`, no manual packaging
step.

> [!NOTE]
> For the full variable reference, state security guidance, and a detailed
> comparison against the Bash implementation, see [`Terraform - README.md`](project/terraform/README.md).
