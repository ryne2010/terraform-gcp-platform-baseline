# Architecture

This repo is a Terraform **GCP platform baseline** (landing zone style).

It focuses on:
- repeatable infrastructure modules
- secure defaults
- policy-as-code gates
- patterns for CI/CD without static service account keys

## What’s included

- Networking primitives (VPC + subnets)
- Org/project conventions (labels, naming)
- Workload Identity Federation (GitHub OIDC) so GitHub Actions can deploy without JSON keys
- Opinionated security posture documented in `docs/org_policies.md`

See `docs/architecture.md` for a longer form write-up.
