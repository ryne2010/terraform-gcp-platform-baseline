# Security

This repo is a baseline intended to demonstrate secure-by-default infrastructure patterns.

## Built-in security controls

- IaC scanning in CI: **tfsec** + **checkov**
- Policy-as-code gate: **OPA conftest** (`policy/terraform.rego`)
- Workload Identity Federation pattern so CI/CD can deploy without static keys (`docs/identity.md`)

## Production hardening ideas

- Enforce org policies described in `docs/org_policies.md`
- Use a remote Terraform state backend with appropriate access controls
- Enable audit logging and export to SIEM
- Pin module versions and use a module registry
