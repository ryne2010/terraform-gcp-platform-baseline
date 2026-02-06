variable "project_id" {
  type        = string
  description = "GCP project ID."
}

variable "region" {
  type        = string
  description = "Default region (for consistency across examples)."
  default     = "us-central1"
}

variable "github_repository" {
  type        = string
  description = "GitHub repository in OWNER/REPO format (e.g., 'my-org/my-repo')."
}

variable "ci_service_account_id" {
  type        = string
  description = "Service account id (account_id) used by Terraform in GitHub Actions."
  default     = "ci-terraform"
}

variable "tfstate_bucket_name" {
  type        = string
  description = "GCS bucket name used for Terraform remote state."
}

variable "workload_identity_pool_id" {
  type        = string
  description = "Workload Identity Pool ID."
  default     = "github-pool"
}

variable "workload_identity_provider_id" {
  type        = string
  description = "Workload Identity Provider ID."
  default     = "github"
}

variable "config_bucket_name" {
  type        = string
  description = "GCS bucket name used to store backend.hcl + terraform.tfvars for CI."
}

variable "enable_config_bucket_write" {
  type        = bool
  description = "If true, grant CI roles/storage.objectAdmin on the config bucket (lets CI update terraform.tfvars)."
  default     = true
}
