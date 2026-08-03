Architecture
============

System Data Flow
----------------

The architecture follows a event-driven serverless pattern:

.. mermaid::

  flowchart TD
    subgraph IAM_Sources["IAM Activity Sources"]
        A1["IAM Users / Admins"]
        A2["Automated CI/CD Pipelines"]
        A3["Privilege Escalation Events"]
    end

    subgraph AWS_Account["AWS Infrastructure"]
        B["AWS CloudTrail<br/><i>(Management Event Capture)</i>"]
        C["Amazon EventBridge<br/><i>(IAM API Event Rule Filter)</i>"]

        subgraph Serverless_Processing["Processing Layer"]
            D["AWS Lambda (Python 3.11)<br/><i>(Event Parser & Risk Analyzer)</i>"]
        end

        subgraph Output_Layer["Response Layer"]
            E["Amazon SNS<br/><i>(Security Alert Topic & Email)</i>"]
            F["Amazon S3 Audit Bucket<br/><i>(JSON Audit Log Archival)</i>"]
            G["Amazon CloudWatch<br/><i>(Logs, Metrics & Alarms)</i>"]
        end
    end

    A1 --> B
    A2 --> B
    A3 --> B

    B --> C
    C --> D

    D --> E
    D --> F
    D --> G

AWS Services & Responsibilities
-------------------------------

* **AWS IAM**: Provides customer-managed policies, groups, users, and execution roles.
* **AWS CloudTrail**: Captures management events and API calls across the account.
* **Amazon EventBridge**: Evaluates CloudTrail events against IAM pattern filters and invokes Lambda.
* **Amazon SNS**: Topic, topic policy, and subscription manager for security alert emails.
* **AWS Lambda**: Python 3.11 handler that analyzes risk, logs JSON audit records to S3, publishes alerts to SNS, and emits metrics to CloudWatch.
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
