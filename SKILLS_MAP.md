# Skills showcased in this repo

This repo is a portfolio artifact for:
- Cloud Platform Engineer (GCP)
- Infrastructure / DevOps Engineer
- Security-minded Terraform practitioner

## Highlights

### Terraform module design
- `modules/*` show reusable patterns and clear variable interfaces
- `environments/*` show how to compose modules

### CI/CD without static keys
- GitHub OIDC / Workload Identity Federation remembering: `docs/identity.md`

### IaC security
- Security scanning: `.github/workflows/terraform-ci.yml` (tfsec + checkov)
- Policy-as-code: `policy/terraform.rego` enforced via conftest

### Governance posture
- Recommended org policy constraints: `docs/org_policies.md`
