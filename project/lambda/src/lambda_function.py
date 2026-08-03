#!/usr/bin/env python3
"""
AWS Lambda function for real-time AWS IAM security auditing and monitoring.

Processes AWS CloudTrail events routed via Amazon EventBridge, categorizes IAM
actions by risk severity, records audit logs in Amazon S3, sends SNS security
alerts for high-risk changes, and emits CloudWatch metrics for monitoring dashboards.

Environment Variables:
  AUDIT_BUCKET   Amazon S3 bucket name for storing audit history logs.
  SNS_TOPIC_ARN  Amazon SNS topic ARN for publishing security alert notifications.
"""

import json
import os
import sys
from datetime import datetime, timezone
import boto3
from botocore.exceptions import ClientError

# Environment variables
S3_BUCKET = os.environ.get("AUDIT_BUCKET")
SNS_TOPIC_ARN = os.environ.get("SNS_TOPIC_ARN")

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


def store_audit(record: dict) -> bool:
    """Store IAM audit event in Amazon S3."""
    if not S3_BUCKET:
        print(
            "[WARN] S3 AUDIT_BUCKET environment variable not set; skipping audit storage."
        )
        return False

    timestamp = datetime.now(timezone.utc)
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
AWS IAM SECURITY ALERT
========================================

Severity     : {record["risk"]}
Action       : {record["action"]}
Actor        : {record["actor"]}
Target       : {record["target"]}
Source IP    : {record["source_ip"]}
AWS Region   : {record["region"]}
Account ID   : {record["account_id"]}
Event Time   : {record["timestamp"]}

----------------------------------------
CloudTrail Event Summary:
The IAM action '{record["action"]}' was executed by '{record["actor"]}' on target '{record["target"]}' from IP address '{record["source_ip"]}'.

Immediate Review Required:
Inspect AWS CloudTrail logs and IAM policy history to verify whether this activity was authorized.
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
                    "Timestamp": datetime.now(timezone.utc),
                }
            ],
        )
        return True
    except ClientError as e:
        print(f"[WARN] Failed to emit CloudWatch metric: {e}")
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
            "timestamp": datetime.now(timezone.utc).isoformat(),
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
    record = {
        "action": action,
        "risk": risk,
        "actor": get_actor(detail),
        "target": get_target(detail),
        "source_ip": get_source_ip(detail),
        "region": detail.get("awsRegion", os.environ.get("AWS_REGION", "unknown")),
        "account_id": detail.get("recipientAccountId", "unknown"),
        "timestamp": detail.get("eventTime", datetime.now(timezone.utc).isoformat()),
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
