# Workload identity (GitHub Actions → GCP)

This repo includes a Workload Identity Federation (WIF) pattern so CI/CD pipelines can deploy to GCP **without long‑lived service account keys**.

## Why it matters

- eliminates static JSON keys in GitHub secrets
- supports short-lived, auditable credentials
- aligns with enterprise cloud security baselines

## Where to look

- Terraform module: `modules/workload_identity/`
- Example usage: `environments/dev/` (or the README examples)

## Typical flow

1. Create a workload identity pool + provider (GitHub OIDC)
2. Create a deployer service account
3. Bind `roles/iam.workloadIdentityUser` so GitHub workflows can impersonate the SA
4. Use the official GitHub Action to obtain an access token at runtime

In GitHub Actions, the workflow would:
- request an OIDC token from GitHub
- exchange it via WIF
- run `terraform plan/apply` with that identity
