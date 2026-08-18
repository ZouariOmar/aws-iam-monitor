Architecture
============

System Data Flow
----------------

The architecture follows a event-driven serverless pattern:

.. mermaid::

  flowchart TD
    subgraph IAM_Events["IAM Activity Sources"]
        A1["IAM Users / Admins"]
        A2["Automated CI/CD Pipelines"]
        A3["Attacker / Compromised Key"]
    end

    subgraph AWS_Account["AWS Account / Organization"]
        B["AWS CloudTrail<br/><i>(Management Event Capture)</i>"]
        C["Amazon EventBridge<br/><i>(IAM API Event Rule Filter)</i>"]

        subgraph Serverless_Processing["Processing Layer"]
            D["AWS Lambda (Python 3.11)<br/><i>(Event Parser & Risk Analyzer)</i>"]
        end

        subgraph Output_Layer["Response & Storage Layer"]
            E["Amazon SNS<br/><i>(Security Alert Topic & Email)</i>"]
            F["Amazon S3 Audit Bucket<br/><i>(JSON Audit Log Archival)</i>"]
            G["Amazon CloudWatch<br/><i>(Logs, Metrics & Alarms)</i>"]
        end
    end

    A1 --> B
    A2 --> B
    A3 --> B

    B -->|Log Events| C
    C -->|Trigger| D

    D -->|Publish High Risk| E
    D -->|Store JSON| F
    D -->|Put Metrics & Logs| G

    classDef aws fill:#FF9900,color:#fff,stroke:#232F3E,stroke-width:2px;
    classDef service fill:#232F3E,color:#fff,stroke:#FF9900,stroke-width:2px;
    class B,C,D aws;
    class E,F,G service;

AWS Services & Responsibilities
-------------------------------

* **AWS IAM**: Provides customer-managed policies, groups, users, and execution roles.
* **AWS CloudTrail**: Captures management events and API calls across the account.
* **Amazon EventBridge**: Evaluates CloudTrail events against IAM pattern filters and invokes Lambda.
* **Amazon SNS**: Topic, topic policy, and subscription manager for security alert emails.
* **AWS Lambda**: Python 3.11 handler that performs IP source validation, analyzes risk, logs JSON audit records to S3, publishes alerts to SNS, and emits metrics to CloudWatch.
* **Amazon S3**: Server-side encrypted storage (AES-256) for audit trails and CloudTrail logs.
* **Amazon CloudWatch**: Log group retention management and custom metrics (``AWSIAMMonitor``).

Deployment Ordering
-------------------

5-Stage Sequential Provisioning (``--up all``):
1. **Stage 1 (IAM)**: Create customer policies (`DevPolicy`, `ProdPolicy`), groups, users, and execution roles.
2. **Stage 2 (CloudTrail)**: Provision log S3 bucket and CloudTrail management trail.
3. **Stage 3 (SNS)**: Create alert topic (`iam-alerts`), policy, and email subscriptions.
4. **Stage 4 (Lambda)**: Provision history S3 bucket, package `lambda_function.py`, and deploy function.
5. **Stage 5 (EventBridge)**: Register rule pattern, attach Lambda target, and grant invocation permissions.

Terraform vs. Bash
-------------------

This same architecture and diagram apply equally to the Terraform
implementation (``project/terraform/``) — the two are independent, equivalent
implementations rather than a sequential pipeline vs. a declarative one being
functionally different. Terraform additionally provisions optional CloudWatch
alarms on the metrics AWS Lambda already emits (``UnauthorizedIPAccess`` and
function ``Errors``), which is a Terraform-only enhancement, not a divergence
in required behavior — see :doc:`../getting_started/terraform` and
``project/terraform/README.md`` for the complete comparison.
