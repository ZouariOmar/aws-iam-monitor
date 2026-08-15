Installation & Configuration
============================

Prerequisites
-------------

Before deploying **aws-iam-monitor**, ensure your environment meets the following requirements:

* **Operating System**: Linux / macOS
* **Shell**: Bash v5.0+
* **Tools**:
  * `aws-cli` (v2.0+)
  * `jq` (v1.6+)
  * `sed` (v4.10+)
  * `zip` (v3.0+)
  * `openssl` (v3.6+)
  * `python3` (v3.11+)
* **AWS Account Access**: Credentials with administrative permissions to manage IAM, CloudTrail, EventBridge, Lambda, SNS, S3, and CloudWatch.


Repository Setup
----------------

Clone the repository and set executable permissions on CLI scripts:

.. code-block:: bash

  git clone https://github.com/ZouariOmar/aws-iam-monitor.git
  cd aws-iam-monitor/project

  chmod +x awsctl \
    lib/* \
    iam/src/* \
    cloud-trail/src/* \
    sns/src/* \
    sns/test/* \
    event-bridge/src/* \
    lambda/src/* \
    event-bridge/test/* \
    lambda/test/*

Environment Configuration (.env)
--------------------------------

Copy the template configuration file to configure optional parameters such as email alert subscriptions:

.. code-block:: bash

  cp .env.example .env

Edit ``.env`` to specify your security alert recipient email:

.. code-block:: ini

  # AWS Region
  AWS_REGION=us-east-1

  # Amazon SNS Security Alert Configuration
  SNS_TOPIC_NAME=iam-alerts
  SNS_ALERT_EMAIL=security-team@example.com

  # CloudTrail Trail Configuration
  TRAIL_NAME=aws-iam-monitor-management-events

  # Lambda Function Configuration
  LAMBDA_FUNCTION_NAME=aws-iam-monitor-lambda
  LAMBDA_ROLE_NAME=aws-iam-monitor-lambda-role

  # EventBridge Rule Configuration
  RULE_NAME=aws-iam-monitor-rule

  # IP Whitelisting (Comma-separated CIDR ranges)
  ALLOWED_IPS=192.168.1.0/24,203.0.113.5/32

AWS Authentication Verification
-------------------------------

Verify that your local environment is authenticated with AWS:

.. code-block:: bash

  aws sts get-caller-identity
