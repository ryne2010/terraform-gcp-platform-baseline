// Terraform remote state (GCS)
// See repo Makefile: `make example-init EXAMPLE=github_actions_wif ...`
terraform {
  backend "gcs" {}
}
