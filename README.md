[![Contributors](https://img.shields.io/badge/CONTRIBUTORS-01-blue?style=plastic)](https://github/ZouariOmar/aws-iam-monitor/graphs/contributors)
[![Forks](https://img.shields.io/badge/FORKS-00-blue?style=plastic)](https://github/ZouariOmar/aws-iam-monitor/network/members)
[![Stargazers](https://img.shields.io/badge/STARS-00-blue?style=plastic)](https://github.com/github/ZouariOmar/aws-iam-monitor/stargazers)
[![Issues](https://img.shields.io/badge/ISSUES-00-blue?style=plastic)](https://github/ZouariOmar/aws-iam-monitor/issues)
[![Apache-2.0 License](https://img.shields.io/badge/LICENSE-GPL3.0-blue?style=plastic)](https://raw.githubusercontent.com/ZouariOmar/aws-iam-monitor/refs/heads/main/LICENSE)
[![Linkedin](https://img.shields.io/badge/Linkedin-7.2k-blue?style=plastic)](https://www.linkedin.com/in/zouari-omar)

<div align="center">

<img src="res/img/aws-iam-monitor-logo.png" width="300">

<h1>aws-iam-monitor</h1>

<h6>Monitor, Audit, Protect, Real-time visibility into AWS IAM changes and access control activity</h6>

![Project](https://img.shields.io/badge/project-generic-blue?style=for-the-badge&logo=github&logoColor=white)
![Open Source](https://img.shields.io/badge/open_source-yes-brightgreen?style=for-the-badge&logo=opensourceinitiative&logoColor=white)
![Status](https://img.shields.io/badge/status-active-success?style=for-the-badge&logo=statuspage&logoColor=white)
![Maintained](https://img.shields.io/badge/maintained-yes-blue?style=for-the-badge&logo=dependabot&logoColor=white)
![Version](https://img.shields.io/badge/version-0.1.0-orange?style=for-the-badge&logo=semver&logoColor=white)
![License](https://img.shields.io/badge/license-Apache2.0-green?style=for-the-badge&logo=open-source-initiative&logoColor=white)
![Automation](https://img.shields.io/badge/category-automation-purple?style=for-the-badge&logo=githubactions&logoColor=white)
![Bash Script](https://img.shields.io/badge/bash_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Docker](https://img.shields.io/badge/docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Linux](https://img.shields.io/badge/linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![DevOps](https://img.shields.io/badge/devops-automation-purple?style=for-the-badge&logo=devops&logoColor=white)
![Cross Platform](https://img.shields.io/badge/cross--platform-supported-success?style=for-the-badge&logo=windows-terminal&logoColor=white)
![Fast](https://img.shields.io/badge/performance-fast-brightgreen?style=for-the-badge&logo=speedtest&logoColor=white)
![Stable](https://img.shields.io/badge/build-stable-success?style=for-the-badge&logo=checkmarx&logoColor=white)
![Community](https://img.shields.io/badge/community-driven-blueviolet?style=for-the-badge&logo=githubsponsors&logoColor=white)

</div>

- [Overview](#overview)
- [Project Flow](#project-flow)
- [Key Features](#key-features)
  - [Real-time Detection](#real-time-detection)
  - [Existing System Audit](#existing-system-audit)
  - [Permission Tracking](#permission-tracking)
  - [IP Whitelists and Conditions](#ip-whitelists-and-conditions)
  - [Centralized Alerts](#centralized-alerts)
  - [Reports and History](#reports-and-history)
- [Usage](#usage)
- [Download](#download)
- [Emailware](#emailware)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

<div align="center">

<img src="res/img/aws-iam-monitor-full-logo.png">

</div>

## Overview

aws-iam-monitor is a real-time AWS IAM auditing and monitoring platform designed
to provide continuous visibility into identity and access management activities
across AWS environments.

The system monitors IAM changes, analyzes **AWS CloudTrail** events, and detects
security-sensitive modifications such as new user creation, permission
changes, role updates, and access policy modifications. By centralizing IAM
activity monitoring, organizations can quickly identify unauthorized changes,
improve security posture, and maintain compliance with cloud governance requirements.

aws-iam-monitor helps security teams understand **who changed what, when, and
from where**, while maintaining a complete historical record of IAM activity
for investigation and auditing purposes.

> [!NOTE]
> The architecture is designed to support **AWS Organizations**.

> [!IMPORTANT]
> In a production deployment, the monitoring Lambda would assume a **read-only IAM**
> role in each member account using AWS STS AssumeRole, enabling centralized IAM
> auditing across the organization.

## Project Flow

```mermaid
flowchart TD
    A["IAM Activity<br/>(User • Role • Policy Changes)"]

    subgraph AWS["AWS Account"]
        B["AWS CloudTrail<br/>Capture IAM API Events"]
        C["Amazon EventBridge<br/>Event Filtering & Routing"]
        D["AWS Lambda (Python)<br/>Event Processing & Analysis"]

        subgraph Processing["Monitoring & Response"]
            E["Amazon SNS<br/>Security Alerts"]
            F["Amazon S3<br/>Audit Reports & History"]
            G["Amazon CloudWatch<br/>Logs & Metrics"]
        end
    end

    A --> B
    B --> C
    C --> D

    D --> E
    D --> F
    D --> G

    G -. Monitoring .-> D
```

```mermaid
flowchart TD
    A["IAM Change"]
    B["AWS CloudTrail"]
    C["Amazon EventBridge"]
    D["AWS Lambda (Python)"]

    E["Amazon SNS<br/>Alerts"]
    F["Amazon S3<br/>Audit Reports"]
    G["Amazon CloudWatch<br/>Logs & Metrics"]

    A --> B
    B --> C
    C --> D

    D --> E
    D --> F
    D --> G

    classDef aws fill:#FF9900,color:#fff,stroke:#232F3E,stroke-width:2px;
    classDef service fill:#232F3E,color:#fff,stroke:#FF9900,stroke-width:2px;

    class B,C,D aws;
    class E,F,G service;
```

## Key Features

### Real-time Detection

Automatically detect IAM changes as they occur, including the creation of
new IAM users, roles, access keys, and other identity-related resources.

### Existing System Audit

Perform comprehensive IAM inventory scans across AWS accounts to identify
existing users, roles, policies, and permissions.

### Permission Tracking

Monitor and analyze changes to IAM roles, policies, and permission boundaries to
detect privilege escalation risks and unauthorized access modifications.

### IP Whitelists and Conditions

Track changes to IAM policy conditions, source IP restrictions, and
network-based access controls to identify unexpected changes in access rules.

### Centralized Alerts

Aggregate IAM security events at the AWS Organization level and deliver
centralized alerts for faster detection and response.

### Reports and History

Generate detailed audit reports and maintain historical IAM activity records for
compliance reviews, security investigations, and forensic analysis.

## Usage

```bash
git clone https://github/ZouariOmar/aws-iam-monitor
cd aws-iam-monitor

make
```

> See [INSTALL.md](/INSTALL.md) for more informations

## Download

You can [download](https://github.com/ZouariOmar/aws-iam-monitor/releases) the latest installable version of aws-iam-monitor for Windows, macOS and Linux.

## Emailware

aws-iam-monitor is an emailware. Meaning, if you liked using this app or it has helped you in any way,
would like you send as an email at <zouariomar20@gmail.com> about anything you'd want to say about
this software. I'd really appreciate it!

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This repository is licensed under the **Apache-2.0**. You are free to use, modify, and distribute the content. See the [LICENSE](LICENSE) file for details.

## Contact

For questions or suggestions, feel free to reach out:

- **github**: [github](https://github/ZouariOmar/aws-iam-monitor)
- **Email**: <zouariomar20@gmail.com>
- **LinkedIn**: [zouari-omar](https://www.linkedin.com/in/zouari-omar)
