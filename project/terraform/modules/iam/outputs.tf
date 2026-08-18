output "dev_policy_arn" {
  description = "ARN of DevPolicy."
  value       = aws_iam_policy.dev.arn
}

output "prod_policy_arn" {
  description = "ARN of ProdPolicy."
  value       = aws_iam_policy.prod.arn
}

output "audit_policy_arn" {
  description = "ARN of AuditPolicy."
  value       = aws_iam_policy.audit.arn
}

output "ip_whitelist_policy_arn" {
  description = "ARN of IPWhitelistPolicy, or null when allowed_ips is empty."
  value       = local.ip_whitelist_configured ? aws_iam_policy.ip_whitelist[0].arn : null
}
