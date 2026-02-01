provider "google" {
  project = var.project_id
  region  = var.region
}

module "core_services" {
  source     = "../../modules/core_services"
  project_id = var.project_id
}

module "artifact_registry" {
  source      = "../../modules/artifact_registry"
  project_id  = var.project_id
  region      = var.region
  repository_id = var.artifact_repo_name
  labels      = {
    app = "terraform-gcp-platform"
    env = "landing-zone"
  }
}

module "service_accounts" {
  source     = "../../modules/service_accounts"
  project_id = var.project_id

  runtime_account_id = var.runtime_service_account_id
  create_ci_account  = true
  ci_account_id      = var.ci_service_account_id
}

module "secrets" {
  source     = "../../modules/secret_manager"
  project_id = var.project_id

  # This module creates *secret containers* only; add secret versions out-of-band.
  secrets = {
    "example-database-url" = {}
    "example-api-key"      = {}
  }
}
