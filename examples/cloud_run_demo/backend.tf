// Terraform remote state (GCS)
//
// Backend config is intentionally provided at init time (bucket + prefix).
// Use the repo Makefile:
//
//   make example-init EXAMPLE=cloud_run_demo PROJECT_ID=... TF_STATE_BUCKET=... 
//
terraform {
  backend "gcs" {}
}
