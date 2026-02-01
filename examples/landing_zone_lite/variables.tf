variable "project_id" {
  type        = string
  description = "GCP project ID."
}

variable "region" {
  type        = string
  description = "Default region."
  default     = "us-central1"
}

variable "env" {
  type        = string
  description = "Environment label (dev|stage|prod) used for resource labels."
  default     = "dev"
}

variable "enable_org_policies" {
  type        = bool
  description = "Whether to apply a small set of project org-policy constraints. Personal projects often cannot apply these."
  default     = false
}

# Workspace IAM (optional)
variable "workspace_domain" {
  type        = string
  description = "Google Workspace domain for group-based IAM (e.g., company.com). If empty, no group IAM bindings are created."
  default     = ""
}

variable "group_prefix" {
  type        = string
  description = "Group email prefix (e.g., platform -> platform-auditors@domain)."
  default     = "platform"
}
