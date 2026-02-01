# Example: Grounded Knowledge Platform (Public Demo)

Deploys the `grounded-knowledge-platform` container to Cloud Run in **PUBLIC_DEMO_MODE**:
- **no uploads**
- **extractive-only**
- **demo corpus bootstrapped at startup**
- optional OCR

This example is designed to be driven via the repo root **Makefile** (remote state, plan/apply separation).

---

## 1) Build & push the image (Artifact Registry)

Recommended (macOS-friendly) Cloud Build approach:

```bash
# Replace PROJECT_ID
IMAGE="us-central1-docker.pkg.dev/PROJECT_ID/platform-images/grounded-knowledge-platform:demo"

# From the grounded-knowledge-platform repo root (not this repo):
gcloud builds submit --tag "$IMAGE" .
```

---

## 2) Deploy with Terraform (remote state)

From this repo (`terraform-gcp-platform`):

```bash
# One-time: create a tfstate bucket (or let example-init do it)
make bootstrap-state

# Apply the example
make example-apply EXAMPLE=grounded_knowledge_demo \
  EXTRA_VARS='-var="image=us-central1-docker.pkg.dev/PROJECT_ID/platform-images/grounded-knowledge-platform:demo"'
```

## Notes
- For a minimal-cost demo, keep `min_instances=0` and a low `max_instances`.
- Add GCP billing budgets/alerts and rate-limit at the edge if you expect traffic.
