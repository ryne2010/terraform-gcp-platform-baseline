# Example: Landing zone lite

This example provisions a **minimal, project-scoped landing zone**:
- enables required APIs
- creates a standard Artifact Registry repo for images
- creates runtime + CI service accounts with least-privilege roles
- creates Secret Manager secret containers (no secret values in state)
- optionally applies a small set of project-level org policy constraints

This is deliberately "lite" so it can be used in a personal GCP project while still demonstrating enterprise patterns.

## Apply

```bash
make bootstrap-state PROJECT_ID=... 
make example-apply EXAMPLE=landing_zone_lite
```

Optional org policies:

```bash
make example-apply EXAMPLE=landing_zone_lite EXTRA_VARS='-var="enable_org_policies=true"'
```

Optional baseline IAM (Google Groups):

```bash
make example-apply EXAMPLE=landing_zone_lite \
  EXTRA_VARS='-var="workspace_domain=yourdomain.com" -var="group_prefix=platform"'
```
