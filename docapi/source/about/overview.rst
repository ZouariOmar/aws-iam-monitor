Overview
========

**aws-iam-monitor** is a production-ready, serverless AWS security solution designed to provide continuous, real-time visibility into Identity and Access Management (IAM) changes across AWS accounts and AWS Organizations.

The system captures management events from **AWS CloudTrail**, filters events with **Amazon EventBridge**, and evaluates security payloads using an **AWS Lambda** function written in Python 3.11.

Monitored Activity Categories
-----------------------------

The platform categorizes IAM operations into distinct risk severity levels:

* **CRITICAL Risk**:
  * ``DeletePolicy``, ``DeleteRolePolicy``, ``DeleteGroupPolicy``, ``DeleteUserPolicy``
  * ``DeactivateMFADevice``, ``DeleteVirtualMFADevice``

* **HIGH Risk**:
  * ``CreateAccessKey``, ``CreateUser``, ``DeleteUser``
  * ``AttachUserPolicy``, ``AttachGroupPolicy``, ``AttachRolePolicy``
  * ``PutUserPolicy``, ``PutGroupPolicy``, ``PutRolePolicy``
  * ``UpdateRole``, ``UpdateAssumeRolePolicy``, ``CreateLoginProfile``, ``UpdateLoginProfile``

* **MEDIUM Risk**:
  * ``CreateRole``, ``CreateGroup``, ``CreatePolicy``, ``CreatePolicyVersion``, ``SetDefaultPolicyVersion``

* **LOW / Informational**:
  * ``GetUser``, ``ListUsers``

Response & Output Handling
--------------------------

1. **S3 Historical Audit Logs**: Every processed event is formatted as a structured JSON object and archived in Amazon S3 under ``iam-audit/YYYY/MM/DD/``.
2. **Real-time SNS Alerts**: High and Critical events trigger immediate security notifications published to Amazon SNS, delivering email notifications to security personnel.
3. **CloudWatch Metrics**: Emits custom metrics under the ``AWSIAMMonitor`` namespace with dimensions for ``Action`` and ``Risk``.
