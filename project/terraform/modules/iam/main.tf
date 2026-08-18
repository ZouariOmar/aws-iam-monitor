# =========================================================
# modules/iam
#
# Demo IAM sandbox (policies, groups, users, optional roles)
# plus the dynamically-generated IP whitelist policy. Mirrors
# project/bash/iam/src/{iamctl,policy_ctl,group_ctl,user_ctl,role_ctl}
# and project/bash/iam/{policies/*.json,res/*.csv} exactly, driven
# by data structures below instead of CSV files.
# =========================================================

locals {
  ip_whitelist_configured = length(var.allowed_ips) > 0

  # Mirrors project/bash/iam/res/groups.csv (group,policy). ProdGroup
  # attaches two policies; the IPWhitelistPolicy entry is filtered out
  # below when no allowed_ips are configured, matching Bash's no-op
  # behavior when ALLOWED_IPS is unset.
  groups_config = {
    ProdGroup = ["ProdPolicy", "IPWhitelistPolicy"]
    DevGroup  = ["DevPolicy"]
    TestGroup = ["AuditPolicy"]
  }

  # Mirrors project/bash/iam/res/users.csv (user,group).
  users_config = {
    ProdAdmin     = "ProdGroup"
    ProdDeveloper = "ProdGroup"
    DevAdmin      = "DevGroup"
    DevDeveloper  = "DevGroup"
    TestAdmin     = "TestGroup"
    TestDeveloper = "TestGroup"
  }

  # Mirrors the first 3 rows of project/bash/iam/res/roles.csv
  # (service=iam). The 4th row (service=lambda, AwsIamMonitorLambdaRole)
  # is deliberately NOT reproduced here — see the roles section below.
  roles_config = {
    ProdRole = "ProdPolicy"
    DevRole  = "DevPolicy"
    TestRole = "AuditPolicy"
  }

  policy_arns = merge(
    {
      DevPolicy   = aws_iam_policy.dev.arn
      ProdPolicy  = aws_iam_policy.prod.arn
      AuditPolicy = aws_iam_policy.audit.arn
    },
    local.ip_whitelist_configured ? { IPWhitelistPolicy = aws_iam_policy.ip_whitelist[0].arn } : {}
  )

  group_policy_pairs = flatten([
    for group, policies in local.groups_config : [
      for policy in policies : {
        key    = "${group}-${policy}"
        group  = group
        policy = policy
      }
      if policy != "IPWhitelistPolicy" || local.ip_whitelist_configured
    ]
  ])
  group_policy_map = { for pair in local.group_policy_pairs : pair.key => pair }
}

# ---------------------------------------------------------------------------
# Managed policies — always created (cheap, no-risk documents); only their
# attachment to groups/users/roles is gated by enable_iam_sandbox /
# enable_iam_roles below.
# ---------------------------------------------------------------------------

data "aws_iam_policy_document" "dev" {
  statement {
    sid       = "DeveloperAccess"
    effect    = "Allow"
    actions   = ["ec2:*", "lambda:*", "logs:*", "cloudwatch:*", "s3:*", "iam:PassRole"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "prod" {
  statement {
    sid       = "FullAccess"
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "audit" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:Describe*", "s3:Get*", "s3:List*", "iam:Get*", "iam:List*",
      "cloudwatch:Get*", "cloudwatch:List*", "logs:Get*", "logs:Describe*", "logs:List*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "dev" {
  name   = "DevPolicy"
  policy = data.aws_iam_policy_document.dev.json
  tags   = var.tags
}

resource "aws_iam_policy" "prod" {
  name   = "ProdPolicy"
  policy = data.aws_iam_policy_document.prod.json
  tags   = var.tags
}

resource "aws_iam_policy" "audit" {
  name   = "AuditPolicy"
  policy = data.aws_iam_policy_document.audit.json
  tags   = var.tags
}

# Dynamically-generated IP whitelist — equivalent of iamctl's
# generate_ip_whitelist_policy(). No-op (no resource created) when
# allowed_ips is empty, exactly matching Bash's early-return behavior.
data "aws_iam_policy_document" "ip_whitelist" {
  count = local.ip_whitelist_configured ? 1 : 0

  statement {
    sid       = "DenyNonWhitelistedIPs"
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    condition {
      test     = "NotIpAddress"
      variable = "aws:SourceIp"
      values   = var.allowed_ips
    }

    condition {
      test     = "Bool"
      variable = "aws:ViaAWSService"
      values   = ["false"]
    }
  }
}

resource "aws_iam_policy" "ip_whitelist" {
  count = local.ip_whitelist_configured ? 1 : 0

  name   = "IPWhitelistPolicy"
  policy = data.aws_iam_policy_document.ip_whitelist[0].json
  tags   = var.tags
}

# ---------------------------------------------------------------------------
# Demo IAM sandbox — groups, users, membership (enable_iam_sandbox)
# ---------------------------------------------------------------------------

resource "aws_iam_group" "sandbox" {
  for_each = var.enable_iam_sandbox ? toset(keys(local.groups_config)) : toset([])

  name = each.key
}

resource "aws_iam_group_policy_attachment" "sandbox" {
  for_each = var.enable_iam_sandbox ? local.group_policy_map : {}

  group      = aws_iam_group.sandbox[each.value.group].name
  policy_arn = local.policy_arns[each.value.policy]
}

# Plain IAM user identities only — no login profile, no access keys, no
# credentials of any kind are created, matching the Bash implementation
# (user_ctl only ever calls `aws iam create-user` / `add-user-to-group`).
resource "aws_iam_user" "sandbox" {
  for_each = var.enable_iam_sandbox ? local.users_config : {}

  name = each.key
}

resource "aws_iam_user_group_membership" "sandbox" {
  for_each = var.enable_iam_sandbox ? local.users_config : {}

  user   = aws_iam_user.sandbox[each.key].name
  groups = [aws_iam_group.sandbox[each.value].name]
}

# ---------------------------------------------------------------------------
# Optional IAM roles (enable_iam_roles — off by default, matching Bash's
# `-r/--role` opt-in flag)
# ---------------------------------------------------------------------------

data "aws_iam_policy_document" "trust_account_root" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# NOTE: project/bash/iam/res/roles.csv has a 4th row
# (service=lambda, role=AwsIamMonitorLambdaRole, policy=LambdaExecutionPolicy)
# that is deliberately NOT reproduced here. It is redundant with the Lambda
# execution role unconditionally created by modules/lambda
# (var.lambda_role_name / "aws-iam-monitor-lambda-role") — both would trust
# lambda.amazonaws.com and carry LambdaExecutionPolicy, serving no distinct
# purpose. This is consistent with Bash's own default behavior too: that CSV
# row is only ever created when `--role` is explicitly passed to `iamctl`.
resource "aws_iam_role" "sandbox" {
  for_each = var.enable_iam_roles ? local.roles_config : {}

  name               = each.key
  assume_role_policy = data.aws_iam_policy_document.trust_account_root.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "sandbox" {
  for_each = var.enable_iam_roles ? local.roles_config : {}

  role       = aws_iam_role.sandbox[each.key].name
  policy_arn = local.policy_arns[each.value]
}
