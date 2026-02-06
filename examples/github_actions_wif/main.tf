module "core_services" {
  source     = "../../modules/core_services"
  project_id = var.project_id

  # Minimum set for WIF + common Terraform workflows.
  services = [
    "serviceusage.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
    "storage.googleapis.com",
  ]
}

# Remote state bucket (bootstrap)
resource "google_storage_bucket" "tfstate" {
  name                        = var.tfstate_bucket_name
  location                    = "US"
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }

  public_access_prevention = "enforced"

  lifecycle_rule {
    condition { age = 90 }
    action { type = "Delete" }
  }

  labels = {
    purpose    = "tfstate"
    managed_by = "terraform"
  }
}

resource "google_service_account" "ci" {
  account_id   = var.ci_service_account_id
  display_name = "Terraform CI (GitHub Actions)"
}

# Least-privilege-ish for a sandbox:
# - state bucket read/write
# - create/update typical demo resources (Cloud Run, AR, IAM bindings, Monitoring/Logging config)
locals {
  ci_project_roles = [
    "roles/run.admin",
    "roles/artifactregistry.admin",
    "roles/iam.serviceAccountUser",
    "roles/monitoring.admin",
    "roles/logging.admin",
    "roles/serviceusage.serviceUsageAdmin",
  ]
}

resource "google_project_iam_member" "ci_roles" {
  for_each = toset(local.ci_project_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.ci.email}"
}

resource "google_storage_bucket_iam_member" "ci_tfstate_object_admin" {
  bucket = google_storage_bucket.tfstate.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.ci.email}"
}

resource "google_storage_bucket_iam_member" "ci_tfstate_bucket_reader" {
  bucket = google_storage_bucket.tfstate.name
  role   = "roles/storage.legacyBucketReader"
  member = "serviceAccount:${google_service_account.ci.email}"
}

# Optional: config bucket for storing backend.hcl + terraform.tfvars (single source of truth for CI)
resource "google_storage_bucket" "config" {
  name                        = var.config_bucket_name
  location                    = "US"
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }

  public_access_prevention = "enforced"

  lifecycle_rule {
    condition { age = 90 }
    action { type = "Delete" }
  }

  labels = {
    purpose    = "config"
    managed_by = "terraform"
  }
}

resource "google_storage_bucket_iam_member" "ci_config_reader" {
  bucket = google_storage_bucket.config.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.ci.email}"
}

resource "google_storage_bucket_iam_member" "ci_config_writer" {
  count  = var.enable_config_bucket_write ? 1 : 0
  bucket = google_storage_bucket.config.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.ci.email}"
}


module "github_oidc" {
  source = "../../modules/github_oidc"

  project_id = var.project_id

  pool_id     = var.workload_identity_pool_id
  provider_id = var.workload_identity_provider_id

  github_repository = var.github_repository

  service_account_email = google_service_account.ci.email
}
