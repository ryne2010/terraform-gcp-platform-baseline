output "wif_provider_resource_name" {
  description = "Set this as GitHub Variable: GCP_WIF_PROVIDER"
  value       = module.github_oidc.workload_identity_provider
}

output "wif_service_account_email" {
  description = "Set this as GitHub Variable: GCP_WIF_SERVICE_ACCOUNT"
  value       = google_service_account.ci.email
}

output "tfstate_bucket" {
  description = "Set this as GitHub Variable: TFSTATE_BUCKET"
  value       = google_storage_bucket.tfstate.name
}

output "config_bucket" {
  description = "Config bucket name (recommended for storing backend.hcl + terraform.tfvars)."
  value       = google_storage_bucket.config.name
}
