# Example: Cloud Run Demo

Minimal baseline that:
- enables required APIs
- (optionally) creates a VPC connector
- creates Artifact Registry
- creates a runtime service account
- deploys a public Cloud Run service (scale-to-zero)

## Apply (recommended)

```bash
make bootstrap-state
make example-apply EXAMPLE=cloud_run_demo
```

## Clean up

```bash
make example-destroy EXAMPLE=cloud_run_demo
```
