// Terraform remote state (GCS)
// Use: `make example-init EXAMPLE=landing_zone_lite ...`
terraform {
  backend "gcs" {}
}
