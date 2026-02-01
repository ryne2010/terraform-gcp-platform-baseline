# Terraform GCP Platform Baseline (Cloud Run-first)

## Quickstart

Run prerequisites + validate:

```bash
make doctor
make validate
```

For GCP-backed examples (remote state):

```bash
make init GCLOUD_CONFIG=personal-portfolio PROJECT_ID=YOUR_PROJECT_ID REGION=us-central1
make auth          # only needed once per machine/user
make doctor-gcp
make bootstrap-state
make example-plan EXAMPLE=cloud_run_demo
```

Opinionated, production-ready Terraform modules and examples for building a **secure, repeatable Google Cloud Platform baseline** optimized for **Cloud Run** workloads.

This repo is designed to support:
- **DevSecOps** delivery (repeatable IaC, CI checks, auditable changes)
- **Platform engineering** patterns (landing-zone-ish baseline, service templates)
- **Low-cost / free-tier-friendly** demos (Cloud Run min instances 0, no always-on infra by default)

> **Cost note:** This repo is written to *minimize* cost, but costs depend on your GCP billing setup and traffic. Use budgets/alerts and scale-to-zero defaults.

---

## What’s inside

### Modules
- `modules/core_services` — enable required GCP APIs (Cloud Run, Artifact Registry, Logging/Monitoring, etc.)
- `modules/network` — VPC + subnets + optional Serverless VPC Access connector
- `modules/artifact_registry` — Docker repository for images
- `modules/service_accounts` — runtime + CI service accounts with least-privilege role bindings
- `modules/secret_manager` — create secret containers (no secret values in Terraform state)
- `modules/cloud_run_service` — Cloud Run v2 service + IAM invoker bindings (public or restricted)
- `modules/github_oidc` — GitHub Actions → GCP Workload Identity Federation (no long-lived keys)

### Examples
- `examples/cloud_run_demo` — minimal baseline + Cloud Run service deployment
- `examples/grounded_knowledge_demo` — deploy the Grounded Knowledge Platform to Cloud Run in safe **PUBLIC_DEMO_MODE**
- `examples/github_actions_wif` — configure WIF for GitHub Actions (Terraform plan/apply without SA keys)
- `examples/landing_zone_lite` — project-scoped landing zone: APIs, IAM, AR, secrets, optional org policies

### CI
- `.github/workflows/terraform-ci.yml` runs:
  - `terraform fmt` + `init` + `validate`
  - **tfsec** and **checkov** IaC security scanning
  - an **OPA conftest** policy gate (`policy/terraform.rego`)

---

## Quick start

### 0) Prereqs
- Terraform **>= 1.5**
- `gcloud` authenticated (`make auth` or `gcloud auth application-default login`)
- A GCP project (recommended: create one manually in the console)

### 1) Bootstrap remote state (recommended)
Create a GCS bucket for Terraform state. You can use either:

**Option A: Makefile (no exports)**

```bash
# Uses your active gcloud project + region by default
make bootstrap-state
```

**Option B: Script**

```bash
./scripts/bootstrap_state_bucket.sh \
  --project YOUR_PROJECT_ID \
  --bucket YOUR_STATE_BUCKET_NAME \
  --location us-central1
```

> In all examples, the backend is `gcs` with config provided at init time (bucket + prefix).

### 2) Deploy an example (Cloud Run demo)

```bash
# Uses remote state; override EXAMPLE=..., TF_STATE_BUCKET=..., etc.
make example-apply EXAMPLE=cloud_run_demo
```

---

## Design principles

- **Cloud Run-first:** scale-to-zero, least privilege runtime identity, optional VPC access.
- **No secrets in state:** `secret_manager` creates *secret containers* only; add secret versions out-of-band.
- **Repeatability:** standard naming, module outputs for composition, minimal required inputs.
- **Secure-by-default:** IAM is explicit, public access is opt-in.

---

## Security posture

- Workload Identity Federation (GitHub OIDC) module: `modules/github_oidc` (see `docs/identity.md`)
- Organization policy posture and rationale: `docs/org_policies.md`
- Custom policy-as-code gate: `policy/terraform.rego`


## Notes on “free” deployments
If you’re hosting a public demo:
- Set Cloud Run `min_instances = 0`
- Keep `max_instances` low
- Prefer small CPU/memory
- Disable always-on resources (NAT, LB, GKE) unless you truly need them
- Set budgets/alerts in GCP billing

---

## License
Apache-2.0 (see `LICENSE`).
