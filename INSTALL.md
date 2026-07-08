# Installation

## Clone Repository

```bash
git https://github/ZouariOmar/aws-iam-monitor
cd aws-iam-monitor
```

## Requirements

- Git
- AWS Account
  - CloudTrail
  - EventBridge
  - Lambda
  - STS AssumeRole
  - SNS
  - S3
  - CloudWatch
- AWS CLI v2
- Python 3.14.6
- uv
- Docker (optional)
- Make (optional)

## Build

```bash
make build
```

## Run

```bash
make run
```

## Docker

```bash
make docker
```
