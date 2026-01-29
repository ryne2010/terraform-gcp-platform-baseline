# Example: Grounded Knowledge Platform (Public Demo)

Deploys the `grounded-knowledge-platform` container to Cloud Run in **PUBLIC_DEMO_MODE**:
- **no uploads**
- **extractive-only**
- **demo corpus bootstrapped at startup**
- optional OCR

## 1) Build & push the image (Artifact Registry)
From the *grounded-knowledge-platform* repo:

```bash
# Configure Docker auth
gcloud auth configure-docker us-central1-docker.pkg.dev

# Build
docker build -t grounded-knowledge-platform:demo .

# Tag (replace PROJECT_ID)
docker tag grounded-knowledge-platform:demo \
  us-central1-docker.pkg.dev/PROJECT_ID/platform-images/grounded-knowledge-platform:demo

# Push
docker push us-central1-docker.pkg.dev/PROJECT_ID/platform-images/grounded-knowledge-platform:demo
```

## 2) Deploy with Terraform
```bash
terraform init
terraform apply \
  -var="project_id=YOUR_PROJECT_ID" \
  -var="image=us-central1-docker.pkg.dev/YOUR_PROJECT_ID/platform-images/grounded-knowledge-platform:demo"
```

## Notes
- For a truly minimal-cost demo, keep `min_instances=0` and a low `max_instances`.
- Add a GCP Billing budget/alerts and rate-limit at the edge (Cloudflare) if you expect traffic.
