# Workload Identity Federation (WIF) for GitHub Actions

This repo supports keyless GitHub Actions authentication to GCP via **Workload Identity Federation (WIF)**.

This is the pattern you want in interviews:
- no long-lived JSON keys
- short-lived OIDC tokens
- auditable infra changes (Terraform)

## What lives where

### In this repo
- `examples/github_actions_wif/` bootsraps:
  - a CI service account
  - a Workload Identity Pool + Provider scoped to your GitHub repo
  - a Terraform state bucket (GCS)
  - a config bucket (GCS) to store `backend.hcl` + `terraform.tfvars`

### In GitHub (per environment)
Store only 3 variables in your GitHub Environment (Repo → Settings → Environments → `<env>` → Variables):
- `GCP_WIF_PROVIDER` (from Terraform output)
- `GCP_WIF_SERVICE_ACCOUNT` (from Terraform output)
- `GCP_TF_CONFIG_GCS_PATH` (a `gs://...` prefix where config lives)

## 1) Bootstrap WIF + CI service account (Terraform)

From `examples/github_actions_wif/`:

```bash
cd examples/github_actions_wif
terraform init
terraform apply   -var="project_id=YOUR_PROJECT"   -var="tfstate_bucket_name=YOUR_PROJECT-tfstate"   -var="config_bucket_name=YOUR_PROJECT-config"   -var="github_repository=OWNER/REPO"
```

Copy outputs into GitHub Environment variables:
- `GCP_WIF_PROVIDER`
- `GCP_WIF_SERVICE_ACCOUNT`

Teaching point:
- WIF answers **how** GitHub authenticates. IAM roles answer **what it can do**.

## 2) Single source of truth config in GCS (recommended)

Instead of scattering Terraform variables across GitHub variables, store two small files in GCS per environment:
- `backend.hcl` (where Terraform state lives)
- `terraform.tfvars` (the desired config)

Example layout:
- `gs://YOUR_PROJECT-config/tf/examples/grounded_knowledge_demo/dev/backend.hcl`
- `gs://YOUR_PROJECT-config/tf/examples/grounded_knowledge_demo/dev/terraform.tfvars`

### Example `backend.hcl`

```hcl
bucket = "YOUR_PROJECT-tfstate"
prefix = "tf/examples/grounded_knowledge_demo/dev"
```

### Example `terraform.tfvars` (for `examples/grounded_knowledge_demo`)

```hcl
project_id   = "YOUR_PROJECT"
region       = "us-central1"
service_name = "grounded-knowledge-demo"

# Use an immutable tag for repeatable deploys (recommended).
image = "us-central1-docker.pkg.dev/YOUR_PROJECT/platform-images/gkp:sha-..."
```

Upload both files:

```bash
# Choose your own env + example
ENV=dev
TF_DIR=examples/grounded_knowledge_demo

CONFIG_BUCKET="YOUR_PROJECT-config"
TF_CONFIG_GCS_PATH="gs://${CONFIG_BUCKET}/tf/${TF_DIR}/${ENV}"

gcloud storage cp "${TF_DIR}/backend.hcl" "${TF_CONFIG_GCS_PATH}/backend.hcl"
gcloud storage cp /path/to/terraform.tfvars "${TF_CONFIG_GCS_PATH}/terraform.tfvars"
```

IAM requirement:
- CI service account needs `roles/storage.objectViewer` for objects under that prefix.

## 3) Workflows included

These workflows download `backend.hcl` + `terraform.tfvars` from `GCP_TF_CONFIG_GCS_PATH` and run Terraform via WIF:
- `.github/workflows/gcp-terraform-plan.yml` (manual)
- `.github/workflows/terraform-apply-gcp.yml` (manual)
- `.github/workflows/terraform-drift.yml` (weekly + manual)

## 4) Optional: push-to-main auto deploy (dev)

If you want "push → apply" automation for the `dev` environment:
- `.github/workflows/gcp-terraform-deploy-dev.yml` runs **after** `terraform-ci` succeeds on `main`.
- Put approvals on your `prod` environment instead of `dev`.

Tip:
- In many teams: PRs run `plan`; merges to `main` run `apply` (dev auto, prod gated by approvals).
