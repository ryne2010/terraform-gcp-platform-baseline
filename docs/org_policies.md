# Organization policies (landing zone posture)

A real GCP landing zone usually pairs Terraform modules with **organization policy constraints**.

This repo keeps the code lightweight, but these are the typical controls you would enforce:

## Identity & credential controls

- Disable service account key creation (`constraints/iam.disableServiceAccountKeyCreation`)
- Disable service account key upload (`constraints/iam.disableServiceAccountKeyUpload`)
- Require workload identity federation for CI/CD where possible

## Storage controls

- Enforce public access prevention on buckets (`public_access_prevention = "enforced"`)
- Enforce uniform bucket-level access

## Sharing / data exfiltration controls

- Domain restricted sharing (`constraints/iam.allowedPolicyMemberDomains`)
- Restrict resource locations (`constraints/gcp.resourceLocations`) in regulated environments

## Networking controls

- Restrict external IPs (`constraints/compute.vmExternalIpAccess`)
- Require VPC Service Controls for sensitive services

## How this repo demonstrates the pattern

- CI includes **tfsec** + **checkov** for IaC scanning
- CI includes an **OPA conftest** gate (`policy/terraform.rego`) to enforce bespoke rules
- Workload identity module demonstrates the no-static-keys approach
