# GitHub Actions → GCP WIF bootstrap (example)

This example bootstraps keyless CI for a single GitHub repo:

- creates a Terraform state bucket (GCS)
- creates a config bucket (GCS) for `backend.hcl` + `terraform.tfvars`
- creates a CI service account
- creates Workload Identity Pool + Provider (GitHub OIDC)
- binds the GitHub repo principalSet to the service account

## Usage

```bash
cd examples/github_actions_wif
terraform init
terraform apply   -var="project_id=YOUR_PROJECT"   -var="region=us-central1"   -var="tfstate_bucket_name=YOUR_PROJECT-tfstate"   -var="config_bucket_name=YOUR_PROJECT-config"   -var="github_repository=OWNER/REPO"
```

## Outputs → GitHub settings

Copy outputs into GitHub repo settings (Repo → Settings → Environments → `<env>` → Variables):

- `GCP_WIF_PROVIDER` (output: `wif_provider_resource_name`)
- `GCP_WIF_SERVICE_ACCOUNT` (output: `wif_service_account_email`)
- `GCP_TF_CONFIG_GCS_PATH` (you choose this; see `docs/WIF_GITHUB_ACTIONS.md`)
