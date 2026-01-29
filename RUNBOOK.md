# Runbook

Operational notes for using this Terraform baseline.

## Local workflow

```bash
terraform fmt -recursive
terraform init
terraform validate
terraform plan
```

## CI workflow

The default GitHub Action:
- checks formatting
- validates configs
- runs **tfsec** + **checkov**
- runs **conftest** against `policy/terraform.rego` (Terraform parsed via `--parser hcl2`)

## Applying to a real GCP org/project

Typical steps:
1. Create a target project (or adopt an existing one)
2. Configure remote state (GCS bucket + lock if desired)
3. Apply modules in an environment folder (e.g., `environments/dev`)
4. Configure CI to deploy using Workload Identity Federation

## Troubleshooting

**Plan/apply fails in CI due to auth**
- Ensure the WIF provider is created and configured
- Ensure the workflow is allowed to impersonate the deployer service account
- Ensure required APIs are enabled in the project

**Conftest fails**
- Review `policy/terraform.rego`
- Decide whether to fix the module or adjust policy (policy should represent org posture)

## Security note

Avoid long-lived service account keys. Prefer WIF and short-lived tokens.
