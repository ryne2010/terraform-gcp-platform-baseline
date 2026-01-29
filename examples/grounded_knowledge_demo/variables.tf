variable "project_id" {
  type        = string
  description = "GCP project ID."
}

variable "region" {
  type        = string
  description = "GCP region."
  default     = "us-central1"
}

variable "service_name" {
  type        = string
  description = "Cloud Run service name."
  default     = "grounded-knowledge-demo"
}

variable "image" {
  type        = string
  description = "Container image URI for grounded-knowledge-platform (push to Artifact Registry)."
}
