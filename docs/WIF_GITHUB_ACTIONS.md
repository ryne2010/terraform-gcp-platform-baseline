# Workload Identity Federation (WIF) for GitHub Actions

This repo includes a reusable module for **GitHub OIDC → GCP Workload Identity Federation**:

- `modules/github_oidc/`

It also includes an example you can apply in a sandbox project to bootstrap keyless CI:

- `examples/github_actions_wif/`

## Why this is “staff-level” infrastructure

- No long-lived service account keys in CI (keyless auth).
- Strong blast-radius controls via:
  - repository-scoped principalSet bindings
  - optional ref/branch conditions
- Repeatable + reviewable (Terraform plan/apply).

## Quickstart (sandbox)

1) Create a new GCP project and enable billing.

2) From `examples/github_actions_wif/`:

```bash
terraform init
terraform apply
```

3) Copy outputs into your GitHub repo settings:

- Variables:
  - `GCP_WIF_PROVIDER`
  - `GCP_WIF_SERVICE_ACCOUNT`

- Variables:
  - `PROJECT_ID`
  - `REGION`
  - `TFSTATE_BUCKET`
  - `TFSTATE_PREFIX`

4) Use the `terraform-apply-gcp.yml` workflow templates in the app repos.

## Notes

- Avoid service account keys for CI whenever possible.
- Prefer least privilege: grant only the roles CI needs to:
  - read/write Terraform state
  - create/update the specific resources in your stacks
