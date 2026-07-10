Security Policy
===============

Supported Versions
------------------

The following versions of **aws-iam-monitor** receive security updates.

.. list-table::
   :header-rows: 1
   :widths: 20 20

   * - Version
     - Supported
   * - 1.x.x
     - Yes
   * - 0.x.x
     - No

Reporting a Vulnerability
-------------------------

If you discover a security vulnerability in **aws-iam-monitor**, please report it responsibly.

How to Report
^^^^^^^^^^^^^

Send an email to **zouariomar20@gmail.com** containing:

* A description of the vulnerability.
* Steps to reproduce the issue.
* The affected version.
* Relevant logs or screenshots.
* A proof of concept, if available.

.. warning::

   Please **do not** report security vulnerabilities through public GitHub
   issues. Use the email address above for responsible disclosure.

Response Process
^^^^^^^^^^^^^^^^

We aim to:

* Acknowledge your report within **48 hours**.
* Investigate and validate the issue.
* Keep you informed throughout the remediation process.
* Release a fix as quickly as practical.
* Credit you for the disclosure, if desired.

Security Practices
------------------

Least Privilege
^^^^^^^^^^^^^^^

* IAM policies should grant only the permissions required.
* Cross-account access should use read-only roles whenever possible.
* AWS STS AssumeRole is recommended for organization-wide deployments.

Secure AWS Integrations
^^^^^^^^^^^^^^^^^^^^^^^

**aws-iam-monitor** integrates with AWS managed services including:

* AWS CloudTrail
* Amazon EventBridge
* AWS Lambda
* Amazon SNS
* Amazon S3
* Amazon CloudWatch
* AWS STS

These services should be configured according to AWS security best practices.

Data Protection
^^^^^^^^^^^^^^^

* Communication with AWS APIs uses HTTPS/TLS.
* Audit reports stored in Amazon S3 should be encrypted at rest.
* Sensitive configuration files should never be committed to the repository.

Secrets Management
^^^^^^^^^^^^^^^^^^

Never commit:

* AWS Access Keys
* AWS Secret Access Keys
* Session Tokens
* ``.env`` files
* Private certificates
* Customer data

Instead, use one of the following:

* IAM Roles
* AWS Secrets Manager
* AWS Systems Manager Parameter Store
* Environment variables

Logging
^^^^^^^

aws-iam-monitor records IAM activity for auditing purposes.

Logs should:

* Exclude secrets and credentials.
* Be retained according to organizational policies.
* Be monitored for suspicious activity.

Dependency Management
^^^^^^^^^^^^^^^^^^^^^

Dependencies should be kept up to date.

Recommended tools include:

* Dependabot
* ``pip-audit``
* ``uv``
* GitHub Dependabot Alerts

Security Contributions
----------------------

Contributors can help improve the project's security by:

* Following secure coding practices.
* Validating all external input.
* Avoiding hard-coded credentials.
* Applying the principle of least privilege.
* Reviewing dependency updates.
* Testing security-sensitive changes before submitting pull requests.

AWS Security Recommendations
----------------------------

For production deployments, consider the following recommendations:

* Enable AWS CloudTrail in all AWS Regions.
* Enable encryption for Amazon S3 buckets.
* Configure Amazon CloudWatch log retention.
* Enable encryption for Amazon SNS topics where appropriate.
* Enable MFA for privileged AWS accounts.
* Rotate IAM credentials regularly.
* Use a dedicated monitoring account within AWS Organizations.

Resources
---------

* AWS Well-Architected Framework – Security Pillar
* AWS IAM Best Practices
* AWS Security Best Practices
* OWASP Secure Coding Practices Checklist
* CWE Top 25 Most Dangerous Software Weaknesses

Thank You
---------

Thank you for helping keep **aws-iam-monitor** secure for the community.
