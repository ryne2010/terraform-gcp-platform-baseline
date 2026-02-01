# GitHub Actions → GCP WIF bootstrap (example)

This example bootstraps keyless CI for a single GitHub repo:

- creates a Terraform state bucket (GCS)
- creates a CI service account
- creates Workload Identity Pool + Provider (GitHub OIDC)
- binds the GitHub repo principalSet to the service account

## Usage

```bash
cd examples/github_actions_wif
terraform init
terraform apply
```

Required variables:

- `project_id`
- `tfstate_bucket_name`
- `github_organization`
- `github_repository`

Example:

```bash
terraform apply \
  -var="project_id=my-sandbox-project" \
  -var="region=us-central1" \
  -var="tfstate_bucket_name=my-sandbox-tfstate" \
  -var="github_organization=my-github-org" \
  -var="github_repository=grounded-knowledge-platform"
```

## Outputs → GitHub settings

Copy outputs into GitHub repo settings:

- Variables:
  - `GCP_WIF_PROVIDER`
  - `GCP_WIF_SERVICE_ACCOUNT`

- Variables:
  - `PROJECT_ID`
  - `REGION`
  - `TFSTATE_BUCKET`
  - `TFSTATE_PREFIX`

Then you can use the apply + drift workflows in the app repos.
