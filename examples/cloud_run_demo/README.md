# Example: Cloud Run Demo

Minimal example that:
- enables required APIs
- creates a VPC + subnet
- creates Artifact Registry (optional for this demo)
- creates a runtime service account
- deploys a public Cloud Run service (scale-to-zero)

## Run
```bash
terraform init
terraform apply -var="project_id=YOUR_PROJECT_ID"
```

## Clean up
```bash
terraform destroy -var="project_id=YOUR_PROJECT_ID"
```
