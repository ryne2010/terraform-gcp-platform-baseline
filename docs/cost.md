# Cost guardrails (GCP)

This repo is designed to keep costs low, but you are responsible for your bill.

## Low-cost defaults
- Cloud Run: `min_instances = 0` (scale-to-zero)
- Cloud Run: modest CPU/memory defaults
- No NAT / no LB / no always-on compute by default
- Terraform remote state in GCS (cheap) with versioning

## Things that can increase cost
- High Cloud Run traffic (requests / CPU time)
- Large Artifact Registry image storage or frequent builds
- Excessive logging volume (set sampling/retention as appropriate)
- Always-on resources (NAT, GKE, VMs, load balancers)

## Recommendations
- Set a Billing Budget + Alerts in GCP.
- Restrict public services unless necessary.
- Rate-limit public demos at the edge (Cloudflare) if applicable.
