Features & Risk Classification
==============================

Real-time Security Monitoring
-----------------------------

* **Instant Detection**: Captures IAM management events from CloudTrail within seconds of execution.
* **Risk Categorization**: Classifies 25+ IAM API actions into `CRITICAL`, `HIGH`, `MEDIUM`, and `LOW` risk tiers.
* **Actor & Target Attribution**: Extracts event user identity, target resource, source IP address, AWS region, and account ID.

IP Whitelisting & Enforcement
-----------------------------

* **Automated Policy Generation**: ``iamctl`` automatically generates an ``IPWhitelistPolicy`` JSON definition based on the ``ALLOWED_IPS`` environment variable.
* **Proactive Blocking**: Denies any IAM activity originating from non-whitelisted IP addresses (when the policy is attached to users or groups).
* **Lambda-level Validation**: The monitoring Lambda performs real-time checks against trusted CIDRs and triggers alerts for unauthorized IP access.
* **Bypass Detection**: Emits ``UnauthorizedIPAccess`` metrics for tracking attempts from blocked addresses.

Automated Alerts & Storage
--------------------------

* **Email Alerting**: Publishes real-time security alerts to Amazon SNS for High and Critical events with automated email delivery.
* **Structured Audit Logging**: Archives JSON audit records in Amazon S3 grouped chronologically (`iam-audit/YYYY/MM/DD/`).
* **CloudWatch Custom Metrics**: Emits `IAMSecurityEvents` count metrics with `Action` and `Risk` dimensions for CloudWatch dashboard integration.

Enterprise Management Tooling
-----------------------------

* **Unified CLI Orchestration**: `./awsctl` manages complete environment creation (`--up`), teardown (`--down`), status reporting (`--status`), and automated testing (`--test`).
* **Idempotency**: All management scripts verify existing infrastructure states before applying changes to prevent duplicate creation or service disruption.
* **Zero External Runtime Dependencies**: Standard Bash v4+, Python 3, and AWS CLI v2 without third-party runtime package requirements.
