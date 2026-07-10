Architecture
============

Project Flow
------------

.. mermaid::

  flowchart TD
    A["IAM Activity"]
    B["AWS CloudTrail"]
    C["Amazon EventBridge"]
    D["AWS Lambda"]

    E["Amazon SNS"]
    F["Amazon S3"]
    G["Amazon CloudWatch"]

    A --> B
    B --> C
    C --> D

    D --> E
    D --> F
    D --> G

Project Architecture Diagram
----------------------------

.. image:: ../_static/aws-iam-monitor-architecture-diagram.png
  :alt: aws-iam-monitor-architecture-diagram
  :align: center
