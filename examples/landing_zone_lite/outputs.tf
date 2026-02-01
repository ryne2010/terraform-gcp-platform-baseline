output "artifact_repo" {
  description = "Artifact Registry repository ID."
  value       = module.artifact_registry.repository_id
}

output "runtime_service_account" {
  description = "Runtime service account email."
  value       = module.service_accounts.runtime_service_account_email
}

output "ci_service_account" {
  description = "CI service account email (if created)."
  value       = module.service_accounts.ci_service_account_email
}

output "secret_names" {
  description = "Secret Manager secret names (no values)."
  value       = module.secrets.secret_names
}
