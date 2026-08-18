#!/usr/bin/env python3
"""
AWS Lambda function for real-time AWS IAM security auditing and monitoring.

Processes AWS CloudTrail events routed via Amazon EventBridge, categorizes IAM
actions by risk severity, records audit logs in Amazon S3, sends SNS security
alerts for high-risk changes, and emits CloudWatch metrics for monitoring dashboards.

IP Whitelist:
  When ALLOWED_IPS is set, every CloudTrail event is checked against the
  configured CIDR ranges before processing. Events from source IPs not in the
  whitelist are denied: an UnauthorizedIPAccess CloudWatch metric is emitted,
  an SNS alert is published, and the handler returns early with status "denied".
  AWS service endpoint sources (e.g. cloudtrail.amazonaws.com) bypass IP
  validation to avoid false positives from internal AWS service calls.

Environment Variables:
  AUDIT_BUCKET   Amazon S3 bucket name for storing audit history logs.
  SNS_TOPIC_ARN  Amazon SNS topic ARN for publishing security alert notifications.
  ALLOWED_IPS    Comma-separated list of trusted IPv4/IPv6 CIDR ranges
                 (e.g. "203.0.113.10/32,197.238.33.0/24"). Leave unset to
                 disable IP filtering entirely.
"""

import ipaddress
import json
import os
import sys
from datetime import UTC, datetime

import boto3
from botocore.exceptions import ClientError

# Environment variables
S3_BUCKET = os.environ.get("AUDIT_BUCKET")
SNS_TOPIC_ARN = os.environ.get("SNS_TOPIC_ARN")
# Comma-separated trusted CIDR ranges (empty string = no IP filtering)
ALLOWED_IPS_RAW = os.environ.get("ALLOWED_IPS", "")

# Monitored IAM actions and risk classifications
MONITORED_ACTIONS = {
    # Critical risk actions
    "DeletePolicy": "CRITICAL",
    "DeleteRolePolicy": "CRITICAL",
    "DeleteGroupPolicy": "CRITICAL",
    "DeleteUserPolicy": "CRITICAL",
    "DeactivateMFADevice": "CRITICAL",
    "DeleteVirtualMFADevice": "CRITICAL",
    # High risk actions
    "CreateAccessKey": "HIGH",
    "CreateUser": "HIGH",
    "DeleteUser": "HIGH",
    "AttachUserPolicy": "HIGH",
    "AttachGroupPolicy": "HIGH",
    "AttachRolePolicy": "HIGH",
    "PutUserPolicy": "HIGH",
    "PutGroupPolicy": "HIGH",
    "PutRolePolicy": "HIGH",
    "UpdateRole": "HIGH",
    "UpdateAssumeRolePolicy": "HIGH",
    "CreateLoginProfile": "HIGH",
    "UpdateLoginProfile": "HIGH",
    # Medium risk actions
    "CreateRole": "MEDIUM",
    "CreateGroup": "MEDIUM",
    "CreatePolicy": "MEDIUM",
    "CreatePolicyVersion": "MEDIUM",
    "SetDefaultPolicyVersion": "MEDIUM",
    # Informational
    "GetUser": "LOW",
    "ListUsers": "LOW",
}

# Lazy AWS SDK clients
_s3_client = None
_sns_client = None
_cw_client = None


def get_s3_client():
    global _s3_client
    if _s3_client is None:
        _s3_client = boto3.client("s3")
    return _s3_client


def get_sns_client():
    global _sns_client
    if _sns_client is None:
        _sns_client = boto3.client("sns")
    return _sns_client


def get_cw_client():
    global _cw_client
    if _cw_client is None:
        _cw_client = boto3.client("cloudwatch")
    return _cw_client


def get_actor(detail: dict) -> str:
    """Extract actor identity from CloudTrail event detail."""
    identity = detail.get("userIdentity", {})
    return (
        identity.get("userName")
        or identity.get("arn")
        or identity.get("principalId")
        or identity.get("type", "unknown")
    )


def get_target(detail: dict) -> str:
    """Extract target resource from CloudTrail event detail."""
    params = detail.get("requestParameters") or {}
    response = detail.get("responseElements") or {}

    return (
        params.get("userName")
        or params.get("roleName")
        or params.get("groupName")
        or params.get("policyArn")
        or params.get("policyName")
        or (response.get("user") or {}).get("userName")
        or (response.get("role") or {}).get("roleName")
        or "unknown"
    )


def get_source_ip(detail: dict) -> str:
    """Extract source IP address from CloudTrail event detail."""
    return detail.get("sourceIPAddress", "unknown")


def _parse_allowed_networks() -> list:
    """Parse ALLOWED_IPS env var into a list of ip_network objects."""
    if not ALLOWED_IPS_RAW:
        return []
    networks = []
    for cidr in ALLOWED_IPS_RAW.split(","):
        cidr = cidr.strip()
        if not cidr:
            continue
        try:
            networks.append(ipaddress.ip_network(cidr, strict=False))
        except ValueError:
            print(f"[WARN] Invalid CIDR in ALLOWED_IPS, skipping: '{cidr}'")
    return networks


# Pre-parsed network list (evaluated once at cold start).
_ALLOWED_NETWORKS = _parse_allowed_networks()


def is_ip_allowed(source_ip: str) -> bool:
    """Return True if source_ip is within a trusted CIDR range.

    Rules:
    - When ALLOWED_IPS is not configured, all IPs are allowed (no filtering).
    - AWS service endpoint strings (ending in .amazonaws.com) are always
      allowed to prevent false positives from internal AWS service calls.
    - source_ip values of 'unknown' are allowed through so that events with
      missing IP data are not silently dropped.
    """
    # No whitelist configured — allow everything.
    if not _ALLOWED_NETWORKS:
        return True

    # AWS internal service sources bypass IP filtering.
    if source_ip.endswith(".amazonaws.com") or source_ip == "unknown":
        return True

    try:
        addr = ipaddress.ip_address(source_ip)
        return any(addr in net for net in _ALLOWED_NETWORKS)
    except ValueError:
        # Non-parseable string (e.g. a service name) — treat as allowed.
        print(f"[WARN] Could not parse source IP '{source_ip}' — treating as allowed")
        return True


def store_audit(record: dict) -> bool:
    """Store IAM audit event in Amazon S3."""
    if not S3_BUCKET:
        print(
            "[WARN] S3 AUDIT_BUCKET environment variable not set; skipping audit storage."
        )
        return False

    timestamp = datetime.now(UTC)
    key = (
        f"iam-audit/"
        f"{timestamp.year:04d}/"
        f"{timestamp.month:02d}/"
        f"{timestamp.day:02d}/"
        f"{record['risk']}-{record['action']}-{timestamp.strftime('%H%M%S%f')}.json"
    )

    try:
        get_s3_client().put_object(
            Bucket=S3_BUCKET,
            Key=key,
            Body=json.dumps(record, indent=2),
            ContentType="application/json",
        )
        print(f"[INFO] Audit record stored in S3: s3://{S3_BUCKET}/{key}")
        return True
    except ClientError as e:
        print(f"[ERROR] Failed to store audit record in S3: {e}", file=sys.stderr)
        return False


def send_alert(record: dict) -> bool:
    """Send SNS security alert notification for high-risk IAM events."""
    if not SNS_TOPIC_ARN:
        print(
            "[INFO] SNS_TOPIC_ARN environment variable not set; skipping alert notification."
        )
        return False

    subject = f"[{record['risk']} RISK] AWS IAM Security Alert: {record['action']}"
    message = f"""========================================
     AWS IAM MONITOR - SECURITY ALERT
========================================

ALERT TYPE
  High-Risk IAM Activity

SEVERITY
  {record["risk"]}

-------------------------------------------------------
EVENT DETAILS
-------------------------------------------------------

  Action.......{record["action"]}
  Actor........{record["actor"]}
  Target.......{record["target"]}
  Source IP....{record["source_ip"]}
  AWS Region...{record["region"]}
  Account ID...{record["account_id"]}
  Event Time...{record["timestamp"]}

-------------------------------------------------------
CLOUDTRAIL EVENT SUMMARY
-------------------------------------------------------

The IAM action '{record["action"]}' was executed by
'{record["actor"]}' on target '{record["target"]}'
from source IP '{record["source_ip"]}'.

-------------------------------------------------------
IMMEDIATE ACTION REQUIRED
-------------------------------------------------------

Review the following:

  1. AWS CloudTrail logs for this event.
  2. IAM policy history and recent changes.
  3. The actor's permissions and authentication context.
  4. The source IP and associated activity.

If this activity was not authorized, take appropriate
containment and remediation measures.

-------------------------------------------------------
AWS IAM MONITOR
Automated Security Notification
"""

    try:
        get_sns_client().publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject=subject[:100],  # SNS Subject limit is 100 chars
            Message=message,
        )
        print(f"[INFO] Security alert published to SNS: {SNS_TOPIC_ARN}")
        return True
    except ClientError as e:
        print(f"[ERROR] Failed to publish SNS alert: {e}", file=sys.stderr)
        return False


def emit_metric(record: dict) -> bool:
    """Emit CloudWatch custom metric for monitoring dashboards."""
    try:
        get_cw_client().put_metric_data(
            Namespace="AWSIAMMonitor",
            MetricData=[
                {
                    "MetricName": "IAMSecurityEvents",
                    "Dimensions": [
                        {"Name": "Action", "Value": record["action"]},
                        {"Name": "Risk", "Value": record["risk"]},
                    ],
                    "Value": 1,
                    "Unit": "Count",
                    "Timestamp": datetime.now(UTC),
                }
            ],
        )
        return True
    except ClientError as e:
        print(f"[WARN] Failed to emit CloudWatch metric: {e}")
        return False


def emit_unauthorized_ip_metric(source_ip: str, actor: str, action: str) -> bool:
    """Emit CloudWatch UnauthorizedIPAccess metric for blocked IP events."""
    try:
        get_cw_client().put_metric_data(
            Namespace="AWSIAMMonitor",
            MetricData=[
                {
                    "MetricName": "UnauthorizedIPAccess",
                    "Dimensions": [
                        {"Name": "SourceIP", "Value": source_ip},
                        {"Name": "Action", "Value": action},
                    ],
                    "Value": 1,
                    "Unit": "Count",
                    "Timestamp": datetime.now(UTC),
                }
            ],
        )
        print(
            f"[INFO] UnauthorizedIPAccess metric emitted "
            f"(SourceIP={source_ip}, Action={action})"
        )
        return True
    except ClientError as e:
        print(f"[WARN] Failed to emit UnauthorizedIPAccess metric: {e}")
        return False


def send_unauthorized_ip_alert(record: dict) -> bool:
    """Send SNS alert for an unauthorised source IP access attempt."""
    if not SNS_TOPIC_ARN:
        print("[INFO] SNS_TOPIC_ARN not set; skipping unauthorized IP alert.")
        return False

    subject = "[SECURITY ALERT] Unauthorized IP Access Attempt Detected"
    message = f"""
========================================
     AWS IAM MONITOR - SECURITY ALERT
========================================

ALERT TYPE
  Unauthorized IP Access

SEVERITY
  CRITICAL

-------------------------------------------------------
BLOCKED REQUEST
-------------------------------------------------------

  Action.......{record["action"]}
  Actor........{record["actor"]}
  Source IP....{record["source_ip"]} [BLOCKED]
  AWS Region...{record["region"]}
  Account ID...{record["account_id"]}
  Event Time...{record["timestamp"]}

-------------------------------------------------------
IP WHITELIST
-------------------------------------------------------

The request originated from a source IP address
that is NOT included in the configured whitelist.

  Allowed CIDRs:
    {ALLOWED_IPS_RAW or "(not configured)"}

-------------------------------------------------------
IMMEDIATE ACTION REQUIRED
-------------------------------------------------------

Review AWS CloudTrail logs for activity originating
from the blocked IP address.

If this activity was not authorized:

  1. Investigate the associated CloudTrail events.
  2. Review the actor's IAM permissions and credentials.
  3. Check for additional activity from the source IP.
  4. Consider blocking the IP at the network perimeter.
  5. Revoke or rotate associated credentials if necessary.

-------------------------------------------------------
AWS IAM MONITOR
Automated Security Notification
"""

    try:
        get_sns_client().publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject=subject[:100],
            Message=message,
        )
        print(
            f"[INFO] Unauthorized IP alert published to SNS: {SNS_TOPIC_ARN} "
            f"(source_ip={record['source_ip']})"
        )
        return True
    except ClientError as e:
        print(
            f"[ERROR] Failed to publish unauthorized IP SNS alert: {e}", file=sys.stderr
        )
        return False


def lambda_handler(event: dict, context) -> dict:
    """Main AWS Lambda handler for processing CloudTrail events."""
    print(f"[DEBUG] Received event: {json.dumps(event)}")

    # Direct test event support
    if event.get("test") is True:
        print("[INFO] Executing Lambda self-test event handler.")
        test_record = {
            "action": event.get("eventName", "CreateUser"),
            "risk": "HIGH",
            "actor": "test-invoker",
            "target": "test-user",
            "source_ip": "127.0.0.1",
            "region": os.environ.get("AWS_REGION", "us-east-1"),
            "account_id": "000000000000",
            "timestamp": datetime.now(UTC).isoformat(),
        }
        store_audit(test_record)
        emit_metric(test_record)
        alert_sent = send_alert(test_record)
        return {
            "status": "processed",
            "test": True,
            "alert_sent": alert_sent,
            "record": test_record,
        }

    # Extract event detail (supports both direct CloudTrail format & EventBridge wrapper)
    detail = event.get("detail", event)
    action = detail.get("eventName")

    if not action:
        print("[INFO] Event contains no IAM eventName action — ignoring.")
        return {"status": "ignored", "reason": "missing_action"}

    if action not in MONITORED_ACTIONS:
        print(f"[INFO] IAM action '{action}' is not in monitored list — ignoring.")
        return {"status": "ignored", "action": action}

    risk = MONITORED_ACTIONS[action]
    source_ip = get_source_ip(detail)

    # ---- IP Whitelist Enforcement -----------------------------------------
    if not is_ip_allowed(source_ip):
        actor = get_actor(detail)
        print(
            f"[WARN] Unauthorized IP access attempt blocked: "
            f"source_ip={source_ip}, action={action}, actor={actor}"
        )
        blocked_record = {
            "action": action,
            "risk": "CRITICAL",
            "actor": actor,
            "target": get_target(detail),
            "source_ip": source_ip,
            "region": detail.get("awsRegion", os.environ.get("AWS_REGION", "unknown")),
            "account_id": detail.get("recipientAccountId", "unknown"),
            "timestamp": detail.get("eventTime", datetime.now(UTC).isoformat()),
        }
        emit_unauthorized_ip_metric(source_ip, actor, action)
        send_unauthorized_ip_alert(blocked_record)
        return {
            "status": "denied",
            "reason": "unauthorized_ip",
            "source_ip": source_ip,
            "action": action,
            "actor": actor,
        }
    # ---- End IP Whitelist Enforcement ------------------------------------

    record = {
        "action": action,
        "risk": risk,
        "actor": get_actor(detail),
        "target": get_target(detail),
        "source_ip": source_ip,
        "region": detail.get("awsRegion", os.environ.get("AWS_REGION", "unknown")),
        "account_id": detail.get("recipientAccountId", "unknown"),
        "timestamp": detail.get("eventTime", datetime.now(UTC).isoformat()),
    }

    print(f"[INFO] Processed IAM Event: {json.dumps(record, indent=2)}")

    # Store audit history log in S3
    store_audit(record)

    # Emit custom metric
    emit_metric(record)

    # Publish alert for High and Critical events
    if risk in ("HIGH", "CRITICAL"):
        send_alert(record)

    return {
        "status": "processed",
        "action": action,
        "risk": risk,
        "actor": record["actor"],
        "target": record["target"],
    }
