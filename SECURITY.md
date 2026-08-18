# Security Policy

- [Security Policy](#security-policy)
  - [Supported Versions](#supported-versions)
  - [Reporting a Vulnerability](#reporting-a-vulnerability)
    - [How to Report](#how-to-report)
    - [Response Process](#response-process)
  - [Security Practices](#security-practices)
    - [Least Privilege](#least-privilege)
    - [IP Whitelisting](#ip-whitelisting)
    - [Idempotent, Safe Operations](#idempotent-safe-operations)
    - [Secure AWS Integrations](#secure-aws-integrations)
    - [Data Protection](#data-protection)
    - [Secrets Management](#secrets-management)
    - [Logging](#logging)
    - [Dependency Management](#dependency-management)
  - [Security Contributions](#security-contributions)
  - [AWS Security Recommendations](#aws-security-recommendations)
  - [Resources](#resources)

## Supported Versions

The following versions of **aws-iam-monitor** receive security updates.

| Version | Supported |
| ------- | :-------: |
| 1.x.x   |    yes    |
| 0.x.x   |    no     |

## Reporting a Vulnerability

If you discover a security vulnerability in **aws-iam-monitor**, please report it responsibly.

### How to Report

Send an email to **<zouariomar20@gmail.com>** containing:

- A description of the vulnerability
- Steps to reproduce
- The affected version
- Any relevant logs or screenshots
- A proof of concept (if available)

Please **do not open a public GitHub issue** for security vulnerabilities.

### Response Process

We aim to:

- Acknowledge your report within **48 hours**
- Investigate and validate the issue
- Keep you informed throughout the remediation process
- Release a security fix as quickly as practical
- Credit you for the disclosure (if desired)

## Security Practices

The project follows security best practices for AWS environments.

### Least Privilege

- IAM policies grant only the permissions required.
- Cross-account access should use read-only roles whenever possible.
- AWS STS AssumeRole is recommended for organization-wide deployments.

### IP Whitelisting

- The system supports automated `IPWhitelistPolicy` generation to restrict IAM actions to trusted networks.
- Continuous monitoring validates the source IP of every IAM event against a pre-configured `ALLOWED_IPS` list.
- Unauthorized access attempts from blocked IPs trigger high-priority alerts and custom CloudWatch metrics.

### Idempotent, Safe Operations

- Both implementations check resource state before creating, updating, or
  deleting it, to avoid duplicate resources and unintended service
  disruptions.
- The Bash implementation's `awsctl` and its `*_ctl` sub-scripts verify
  existence/hashes before acting; the Terraform implementation relies on
  Terraform's own state-diffing (`terraform plan`) for the same guarantee,
  a second `terraform plan` after `apply` should show no changes.

### Secure AWS Integrations

aws-iam-monitor relies on AWS managed services including:

- AWS CloudTrail
- Amazon EventBridge
- AWS Lambda
- Amazon SNS
- Amazon S3
- Amazon CloudWatch
- AWS STS

These services should be configured according to AWS security best practices.

### Data Protection

- Communication with AWS APIs uses HTTPS/TLS.
- Audit reports stored in Amazon S3 should use encryption at rest.
- Sensitive configuration should never be committed to the repository.

### Secrets Management

Never commit:

- AWS Access Keys
- Secret Access Keys
- Session Tokens
- `.env` files
- Private certificates
- Customer data

Use one of the following instead:

- IAM Roles
- AWS Secrets Manager
- AWS Systems Manager Parameter Store
- Environment variables

### Logging

aws-iam-monitor records IAM activity for auditing purposes.

Logs should:

- Exclude secrets and credentials
- Be retained according to organizational policies
- Be monitored for suspicious activity

### Dependency Management

Dependencies should be kept up to date.

Recommended tools include:

- Dependabot
- `pip-audit`
- `uv`
- GitHub Dependabot Alerts

## Security Contributions

Contributors can help improve security by:

- Following secure coding practices
- Validating all external input
- Avoiding hard-coded credentials
- Using least-privilege IAM permissions
- Reviewing dependency updates
- Testing security-sensitive changes before submitting pull requests

## AWS Security Recommendations

For production deployments, we recommend:

- Enable AWS CloudTrail in all regions.
- Enable S3 bucket encryption.
- Enable CloudWatch log retention.
- Use SNS encryption where appropriate.
- Enable MFA for privileged AWS accounts.
- Rotate IAM credentials regularly.
- Use dedicated monitoring accounts within AWS Organizations.

## Resources

- AWS Well-Architected Framework – Security Pillar
- AWS IAM Best Practices
- AWS Security Best Practices
- OWASP Secure Coding Practices Checklist
- CWE Top 25 Most Dangerous Software Weaknesses

Thank you for helping keep **aws-iam-monitor** secure.
