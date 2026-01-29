provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

module "service_accounts" {
  source     = "../../modules/service_accounts"
  project_id = var.project_id

  create_ci_account = true
  ci_account_id     = var.ci_account_id
}

module "github_oidc" {
  source = "../../modules/github_oidc"

  project_id            = var.project_id
  service_account_email = module.service_accounts.ci_service_account_email
  github_repository     = var.github_repository
  allowed_branches      = var.allowed_branches
}
