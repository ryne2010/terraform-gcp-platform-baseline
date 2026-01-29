# Optional: remote state backend (recommended).
# Uncomment and configure after you create a GCS bucket with ./scripts/bootstrap_state_bucket.sh

# terraform {
#   backend "gcs" {
#     bucket = "YOUR_TFSTATE_BUCKET"
#     prefix = "terraform-gcp-platform-baseline/examples/cloud_run_demo"
#   }
# }
