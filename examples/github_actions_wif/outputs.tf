output "ci_service_account_email" {
  value       = module.service_accounts.ci_service_account_email
  description = "CI service account email."
}

output "workload_identity_provider" {
  value       = module.github_oidc.workload_identity_provider
  description = "WIF provider name for GitHub Actions."
}
