# Changelog

<!--toc:start-->

- [Changelog](#changelog)
  - [1.1.0 - 2026-08-15](#1.1.0--2026-08-15)
    - [Features](#features)
    - [Bug Fixes](#bug-fixes)
    - [Refactor](#refactor)
    - [Documentation](#documentation)
    - [Miscellaneous Tasks](#miscellaneous-tasks)
  - [1.0.0 - 2026-08-03](#1.0.0---2026-08-03)
    - [Features](#features-1)
    - [Refactor](#refactor-1)
    - [Documentation](#documentation-1)
    - [Miscellaneous Tasks](#miscellaneous-tasks-1)
  - [0.1.0 - 2026-07-25](#0.1.0---2026-07-25)
    - [Features](#features-2)
    - [Other](#other)
    - [Refactor](#refactor-2)
    - [Documentation](#documentation-2)
    - [Miscellaneous Tasks](#miscellaneous-tasks-2)

<!--toc:end-->

## 1.1.0 - 2026-08-15

### Features

- _(lambda)_ Enforce source IP whitelist
- _(iam)_ Add IP whitelist policy provisioning
- _(tooling)_ Improve `Docker` workflow & `Makefile`

### Bug Fixes

- _(Makefile)_ Correct Makefile version variable handling
- _(sns)_ Handle subscription states correctly
- _(cloud-trail)_ Pass region to S3 status checks

### Refactor

- _(lambda)_ Modernize timestamps and security alerts

### Documentation

- _(security)_ Update project docs

### Miscellaneous Tasks

- _(release)_ V1.1.0

## 1.0.0 - 2026-08-03

### Features

- _(event-bridge)_ Add `IAM CloudTrail` event pattern policy
- _(event-bridge)_ Add `EventBridge` rule management controller
- _(awsctl)_ Integrate EventBridge into infrastructure lifecycle management
- _(cloud-trail)_ Display event selectors in trail status
- _(iam)_ Support custom IAM role trust policies
- _(lambda)_ Add Lambda execution policies
- _(lib)_ Add environment file loading helper
- _(common)_ Add ARN builder helper
- _(sns)_ Add SNS topic lifecycle management for IAM alerts
- _(awsctl)_ Extend orchestration for sns & lambda pipeline

### Refactor

- _(iam)_ Change `load` script location
- _(s3)_ Split `S3 bucket` management from `CloudTrail` controller
- _(iamctl)_ Move usage function before iam setup logic
- _(lambda)_ Move lambda policies into `lambda/policies/*`
- _(banner)_ Change `event-bridge` & `cloud-trail` banner
- _(cloudtrail)_ Improve trail and bucket management scripts
- _(event-bridge)_ Enhance EventBridge rule lifecycle management
- _(iam)_ [**breaking**] Redesign IAM controller CLI contracts
- _(iam)_ [**breaking**] Add Lambda-based IAM monitoring & audit workflow
- _(lib)_ Improve shared library utilities

### Documentation

- _(README)_ Update architecture & usage documentation
- _(docsapi)_ Update architecture & usage documentation

### Miscellaneous Tasks

- _(boto3)_ Add boto3 dependency
- _(release)_ V1.0.0

## 0.1.0 - 2026-07-25

### Features

- _(aws)_ Add IAM setup automation & policy templates
- _(iam)_ Add IAM policy version management
- _(iam)_ Add IAM teardown automation
- _(cli)_ Add IAM lifecycle management command
- _(cloudtrail)_ Add CloudTrail resource management module
- _(cli)_ Add awsctl orchestration command

### Other

- _(vercel)_ Add vercel deployment commands for documentation

### Refactor

- _(aws)_ Move AWS files from `project/aws` to `project`
- _(iam)_ Extract shared functions into `common` library
- _(iam)_ Use groups for user role assignment
- _(iam)_ Replace hardcoded account id in trust policy
- _(iam)_ Improve CLI initialization & error handling
- _(iam)_ Reorganize IAM resources and management scripts
- _(lib)_ Improve shared script reliability and execution handling

### Documentation

- _(security)_ Improve security policy documentation
- _(architecture)_ Add AWS IAM monitor architecture diagram
- _(sphinx)_ Add project documentation site
- _(problem)_ Add IAM AWS audit presentation slides

### Miscellaneous Tasks

- _(tooling)_ Add `uv` project setup & improve `Makefile` workflow
- _(iam)_ Reorganize IAM resources & add role configuration files
