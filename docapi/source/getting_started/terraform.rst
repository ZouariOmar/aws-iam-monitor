Terraform Usage
===============

This page documents the Terraform implementation, located in
``project/terraform/``. It provisions the same core architecture as the Bash
implementation (see :doc:`usage`) declaratively. Full reference documentation,
including the variable table and a detailed comparison against Bash, lives in
`project/terraform/README.md
<https://github.com/ZouariOmar/aws-iam-monitor/blob/main/project/terraform/README.md>`_.

.. warning::
  Do not run both implementations against the same AWS account
  simultaneously — they use the same default resource names and would
  conflict.

Command Syntax
---------------

.. code-block:: bash

  cd project/terraform

  terraform init
  terraform plan
  terraform apply
  terraform destroy

Or via the dedicated Makefile: ``make -C project/terraform <init|plan|apply|destroy>``,
or the root Makefile's delegation targets: ``make tf-init``, ``make tf-plan``,
``make tf-apply``, ``make tf-destroy``.

Variables Overview
--------------------

Configuration is entirely variable-driven via ``terraform.tfvars`` (copied
from ``terraform.tfvars.example``) — Terraform does not read the Bash
implementation's ``.env`` file. Key variables:

* ``aws_region`` — matches Bash's ``AWS_REGION`` (default ``us-east-1``)
* ``enable_iam_sandbox`` — creates the demo IAM groups/users (default ``true``,
  matching ``./awsctl --up all``)
* ``enable_iam_roles`` — creates optional IAM roles (default ``false``,
  matching Bash's ``-r``/``--role`` flag)
* ``allowed_ips`` — trusted CIDR list, matches Bash's ``ALLOWED_IPS``
  (default ``[]``, no filtering)
* ``sns_alert_email`` — matches Bash's ``SNS_ALERT_EMAIL`` (default ``""``)
* ``enable_cloudwatch_alarms`` — Terraform-only enhancement, creates alarms on
  the Lambda-emitted metrics (default ``true``)

See ``project/terraform/README.md`` for the complete variable table.

Deployment & Workflow Examples
--------------------------------

1. Deploy Full Environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

  cd project/terraform
  cp terraform.tfvars.example terraform.tfvars
  terraform init
  terraform apply

A plain ``terraform apply`` with default variables provisions the same
architecture as ``./awsctl --up all``, including the demo IAM sandbox.

2. Updating Infrastructure
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Edit a variable in ``terraform.tfvars`` and re-run ``terraform plan`` /
``terraform apply``. Changes to the shared Lambda source
(``project/bash/lambda/src/lambda_function.py``) are detected automatically
via ``source_code_hash`` and redeployed on the next ``apply`` — no manual
packaging step.

3. Teardown Full Environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

  terraform destroy

Terraform State Security
--------------------------

State is local by default (``terraform.tfstate``, gitignored) — fine for
solo use, but not safe for teams. For shared/production use, configure a
remote backend (S3 + DynamoDB locking, or Terraform Cloud). See
``project/terraform/README.md`` for an example backend configuration and
further state-security guidance.
