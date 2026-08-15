CLI Usage & Command Reference
=============================

The primary orchestration interface is ``./awsctl`` located in the ``project/`` directory.

Command Syntax
--------------

.. code-block:: bash

  ./awsctl <ACTION> [TARGET] [OPTIONS]

Actions
-------

* ``--up`` : Provision and configure infrastructure components.
* ``--down`` : Tear down and delete infrastructure components.
* ``--status`` : Display health, configuration, and state of components.
* ``--test`` : Execute automated component and end-to-end test suites.

Targets
-------

* ``all`` *(default)* : Complete end-to-end monitoring pipeline.
* ``iam`` : IAM policies (including automated ``IPWhitelistPolicy``), groups, users, and optional roles.
* ``cloud-trail`` : CloudTrail management events trail and S3 log bucket.
* ``sns`` : Amazon SNS security alert topic, policy, and email subscriptions.
* ``lambda`` : Monitoring Lambda function, execution role, and S3 audit bucket.
* ``event-bridge`` : EventBridge rule, CloudTrail filtering, and Lambda target.

Options
-------

* ``-r, --role`` : Include optional IAM roles during IAM setup.
* ``-v, --verbose`` : Display detailed AWS CLI execution logs.
* ``-h, --help`` : Show help message and usage syntax.

Deployment & Workflow Examples
------------------------------

1. Deploy Full Environment
~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

  ./awsctl --up all

Orchestrates a 5-stage sequential deployment:
1. **IAM**: Customer-managed policies, groups, users, and execution roles.
2. **CloudTrail**: Management events logging & S3 log bucket.
3. **SNS**: Security alert topic (`iam-alerts`) and email subscription.
4. **Lambda**: Event parser function, S3 audit history bucket, and CloudWatch log retention.
5. **EventBridge**: Rule pattern registration, target attachment, and Lambda permissions.

2. Target-Specific Operations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

  # Manage SNS component only
  ./awsctl --up sns

  # Check status of complete monitoring infrastructure
  ./awsctl --status all

  # Execute automated tests on EventBridge component
  ./awsctl --test event-bridge

3. Teardown Full Environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

  ./awsctl --down all

Executes a 5-stage reverse teardown sequence (`EventBridge` -> `Lambda` -> `SNS` -> `CloudTrail` -> `IAM`).
