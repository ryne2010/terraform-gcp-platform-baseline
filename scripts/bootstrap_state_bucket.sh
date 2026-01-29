#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 --project PROJECT_ID --bucket BUCKET_NAME [--location LOCATION]

Creates a GCS bucket for Terraform remote state with:
- uniform bucket-level access
- versioning enabled

Example:
  $0 --project my-proj --bucket my-proj-tfstate --location us-central1
EOF
}

PROJECT=""
BUCKET=""
LOCATION="us-central1"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT="$2"; shift 2;;
    --bucket) BUCKET="$2"; shift 2;;
    --location) LOCATION="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1"; usage; exit 1;;
  esac
done

if [[ -z "$PROJECT" || -z "$BUCKET" ]]; then
  echo "Missing required args."
  usage
  exit 1
fi

echo "Creating bucket gs://$BUCKET in project $PROJECT..."
gcloud storage buckets create "gs://$BUCKET" \
  --project="$PROJECT" \
  --location="$LOCATION" \
  --uniform-bucket-level-access

echo "Enabling versioning..."
gcloud storage buckets update "gs://$BUCKET" --versioning

echo "Done."
