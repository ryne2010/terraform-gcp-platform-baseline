// Terraform remote state (GCS)
// See repo Makefile: `make example-init EXAMPLE=grounded_knowledge_demo ...`
terraform {
  backend "gcs" {}
}
