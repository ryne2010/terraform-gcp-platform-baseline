variable "project_id" {
  type        = string
  description = "GCP project ID."
}

variable "region" {
  type        = string
  description = "GCP region."
  default     = "us-central1"
}

variable "subnet_cidr" {
  type        = string
  description = "CIDR range for the example subnet."
  default     = "10.10.0.0/24"
}

variable "service_name" {
  type        = string
  description = "Cloud Run service name."
  default     = "hello-platform"
}

variable "image" {
  type        = string
  description = "Container image to deploy."
  default     = "gcr.io/cloudrun/hello"
}
