provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

module "core_services" {
  source     = "../../modules/core_services"
  project_id = var.project_id
}

module "artifact_registry" {
  source        = "../../modules/artifact_registry"
  project_id    = var.project_id
  location      = var.region
  repository_id = "platform-images"
}

module "service_accounts" {
  source     = "../../modules/service_accounts"
  project_id = var.project_id

  runtime_account_id = "sa-runtime"
  create_ci_account  = false
}

module "grounded_knowledge" {
  source = "../../modules/cloud_run_service"

  project_id            = var.project_id
  region                = var.region
  service_name          = var.service_name
  image                 = var.image
  service_account_email = module.service_accounts.runtime_service_account_email

  # Public demo site (read-only) — safe defaults are enforced by the app when PUBLIC_DEMO_MODE=1.
  allow_unauthenticated = true

  min_instances = 0
  max_instances = 2
  cpu           = "1"
  memory        = "512Mi"

  env_vars = {
    "PUBLIC_DEMO_MODE"      = "1"
    "BOOTSTRAP_DEMO_CORPUS" = "1"
    "LLM_PROVIDER"          = "extractive"
    "EMBEDDINGS_BACKEND"    = "hash"
    "OCR_ENABLED"           = "1"
    "APP_ENV"               = "demo"
  }

  labels = {
    "app" = "grounded-knowledge-platform"
  }
}
