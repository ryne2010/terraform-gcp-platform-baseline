# Google Groups IAM patterns

In enterprise and government environments, **Google Groups** (backed by Google Workspace / Cloud Identity) are a common way to standardize access.

This portfolio uses a simple, repeatable scheme:

- **platform** groups (project-wide):
  - `platform-platform-admins@<domain>`
  - `platform-auditors@<domain>`
  - `platform-engineers@<domain>`

- **app** groups (service-focused):
  - `gkp-engineers@<domain>`
  - `eventpulse-engineers@<domain>`
  - `edgewatch-engineers@<domain>`
  - ...and their `*-engineers-min` / `*-clients-observers` variants

Why this design is useful:
- the membership list is easy to audit
- onboarding/offboarding is a group change, not a policy edit
- Terraform can express IAM as code with clear review diffs

Where it’s implemented in this portfolio:
- `examples/landing_zone_lite/iam_bindings.tf` (project-wide baseline)
- application repos include `iam_bindings.tf` in their Cloud Run Terraform roots
