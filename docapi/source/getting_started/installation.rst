Installation
============

Requirements
------------

* Git
* AWS Account

  * CloudTrail
  * EventBridge
  * Lambda
  * STS AssumeRole
  * SNS
  * S3
  * CloudWatch

* AWS CLI v2
* Python 3.14+
* uv
* Docker (optional)
* Make (optional)

Clone the repository
--------------------

.. code-block:: bash

  git clone https://github.com/ZouariOmar/aws-iam-monitor.git
  cd aws-iam-monitor

Build
-----

.. code-block:: bash

  make build

Run
---

.. code-block:: bash

  make run

Docker
------

.. code-block:: bash

  make docker
