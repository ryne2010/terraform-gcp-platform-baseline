variable "project_id" {
  type        = string
  description = "GCP project ID."
}

variable "github_repository" {
  type        = string
  description = "GitHub repo in OWNER/REPO format."
}

variable "allowed_branches" {
  type        = list(string)
  description = "Branches allowed for OIDC authentication."
  default     = ["main"]
}

variable "ci_account_id" {
  type        = string
  description = "Service account ID for CI."
  default     = "sa-ci"
}
