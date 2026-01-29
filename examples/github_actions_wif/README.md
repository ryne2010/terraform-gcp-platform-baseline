# Example: GitHub Actions Workload Identity Federation (WIF)

Configures GitHub Actions OIDC for Terraform runs **without** long-lived keys.

## Run
```bash
terraform init
terraform apply -var="project_id=YOUR_PROJECT_ID" -var="github_repository=OWNER/REPO"
```

## Next steps
Add these GitHub repo secrets:
- `GCP_WIF_PROVIDER` = `terraform output -raw workload_identity_provider`
- `GCP_SA_EMAIL` = `terraform output -raw ci_service_account_email`

Then use `workflow.example.yml` as a starting point.
