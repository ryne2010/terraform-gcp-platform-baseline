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

module "network" {
  source     = "../../modules/network"
  project_id = var.project_id

  network_name = "platform-vpc"
  subnets = {
    "platform-subnet-${var.region}" = {
      region = var.region
      cidr   = var.subnet_cidr
    }
  }
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

module "hello_service" {
  source = "../../modules/cloud_run_service"

  project_id            = var.project_id
  region                = var.region
  service_name          = var.service_name
  image                 = var.image
  service_account_email = module.service_accounts.runtime_service_account_email

  allow_unauthenticated = true
  min_instances         = 0
  max_instances         = 2

  env_vars = {
    "PLATFORM" = "terraform-gcp-platform-baseline"
  }

  labels = {
    "repo" = "terraform-gcp-platform-baseline"
  }

  # If you need VPC access:
  # vpc_connector_id = module.network.serverless_connector_id
}
