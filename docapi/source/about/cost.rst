Cost Estimate
=============

Both the Bash and the Terraform implementations provision the same resources,
so they share the same cost profile.

The figures below are modeled with the `AWS Pricing Calculator
<https://calculator.aws>`_, Region **US East (N. Virginia)**, at standard
on-demand rates **with the AWS Free Tier not applied**, for a baseline of
roughly **50,000 IAM management events per month**.

.. list-table:: Monthly cost breakdown (no Free Tier)
  :header-rows: 1
  :widths: 22 53 15

  * - AWS service
    - Basis
    - Est. / month
  * - AWS CloudTrail
    - 50k IAM management events @ $2.00 / 100k
    - $1.00
  * - Amazon EventBridge
    - AWS service events on the default bus (no charge)
    - $0.00
  * - AWS Lambda
    - 50k requests · 128 MB · ~400 ms (~2,500 GB-s)
    - $0.05
  * - Amazon SNS
    - 50k publishes + ~500 email deliveries
    - $0.04
  * - Amazon S3
    - ~10 GB Standard storage · ~55k PUT/GET requests
    - $0.51
  * - Amazon CloudWatch
    - 3 custom metrics · 2 alarms · 50k ``PutMetricData`` · ~1 GB logs
    - $2.13
  * - Data transfer
    - Intra-region + minimal internet egress
    - $0.09
  * - **Estimated total**
    -
    - **≈ $3.82**

That is **≈ $3.82 / month (~$46 / year)**. Cost scales almost entirely with the
IAM event volume:

.. list-table::
  :header-rows: 1
  :widths: 30 35 35

  * - Activity level
    - IAM events / month
    - Est. / month
  * - Light
    - 5k
    - ≈ $2
  * - Moderate
    - 50k
    - ≈ $4
  * - Heavy
    - 500k
    - ≈ $24

.. note::

  Amazon CloudWatch dominates the bill — custom metrics plus one
  ``PutMetricData`` call per event. Batching metric publishes, or emitting
  fewer custom metrics, reduces it further. Within the AWS Free Tier most line
  items fall to $0 and the effective total is negligible.
