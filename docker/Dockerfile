# Lightweight container image for validating the Terraform baseline
# (useful for reproducible CI/CD runners)

FROM hashicorp/terraform:1.8.5

WORKDIR /workspace
COPY . /workspace

# Smoke: ensure terraform is present
RUN terraform -version
