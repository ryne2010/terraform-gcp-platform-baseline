# Terraform GCP Platform Baseline — team-ready workflow (Makefile)
#
# This repo is a baseline module library plus examples. The Makefile provides:
# - consistent commands for local dev and CI
# - remote state workflows for examples (GCS backend)
# - a "staff-level" posture (formatting, linting, security scanning hooks)
#
# Common flows:
#   make fmt validate
#   make bootstrap-state PROJECT_ID=my-proj
#   make example-plan EXAMPLE=cloud_run_demo
#   make example-apply EXAMPLE=cloud_run_demo
#
# Example overrides:
#   make example-apply EXAMPLE=grounded_knowledge_demo EXTRA_VARS='-var="image=..."'
#   make example-apply EXAMPLE=github_actions_wif EXTRA_VARS='-var="github_repository=OWNER/REPO"'

SHELL := /bin/bash

PROJECT_ID ?= $(shell gcloud config get-value project 2>/dev/null)
REGION     ?= $(shell gcloud config get-value run/region 2>/dev/null)
REGION     ?= us-central1

# Example to operate on
EXAMPLE ?= cloud_run_demo
EXAMPLE_DIR := examples/$(EXAMPLE)

# Remote state defaults for examples
TF_STATE_BUCKET ?= $(PROJECT_ID)-tfstate
TF_STATE_PREFIX ?= terraform-gcp-platform/examples/$(EXAMPLE)

# Additional terraform vars to pass to example plan/apply
# Example:
#   EXTRA_VARS='-var="image=us-central1-docker.pkg.dev/..."'
EXTRA_VARS ?=

# -----------------------------
# Helpers
# -----------------------------

define require
	@command -v $(1) >/dev/null 2>&1 || (echo "Missing dependency: $(1)"; exit 1)
endef

.PHONY: help init auth doctor doctor-gcp \
	fmt validate \
	bootstrap-state \
	tflint tfsec checkov conftest scan \
	example-init example-plan example-apply example-destroy

help:
	@echo "Core targets:"
	@echo "  init              One-time setup for GCP examples (persist gcloud project/region)"
	@echo "  auth              Authenticate gcloud user + ADC (interactive)"
	@echo "  fmt               terraform fmt -recursive"
	@echo "  validate           terraform validate (root + examples; backend disabled for validate)"
	@echo ""
	@echo "GCP example targets (remote state):"
	@echo "  bootstrap-state    create GCS bucket for tfstate (gs://$${TF_STATE_BUCKET})"
	@echo "  example-init       terraform init for examples/$(EXAMPLE) using GCS backend"
	@echo "  example-plan       terraform plan (EXTRA_VARS=...)"
	@echo "  example-apply      terraform apply (EXTRA_VARS=...)"
	@echo "  example-destroy    terraform destroy (EXTRA_VARS=...)"
	@echo ""
	@echo "Security/lint hooks (optional locally; required in CI):"
	@echo "  tflint             run tflint"
	@echo "  tfsec              run tfsec"
	@echo "  checkov            run checkov"
	@echo "  conftest           run OPA conftest gate"
	@echo "  scan               run tfsec + checkov + conftest"
	@echo ""
	@echo "Resolved config (override with VAR=...):"
	@echo "  PROJECT_ID=$(PROJECT_ID)"
	@echo "  REGION=$(REGION)"
	@echo "  EXAMPLE=$(EXAMPLE)"
	@echo "  TF_STATE_BUCKET=$(TF_STATE_BUCKET)"
	@echo "  TF_STATE_PREFIX=$(TF_STATE_PREFIX)"



# -----------------------------
# Init (team onboarding)
# -----------------------------
# `make init` persists `PROJECT_ID` and `REGION` into your active gcloud configuration.
# This avoids copy/pasting `export ...` blocks and keeps multi-repo workflows consistent.
#
# Usage (recommended for teams):
#   make init GCLOUD_CONFIG=personal-portfolio PROJECT_ID=my-proj REGION=us-central1
#
# Usage (current gcloud config):
#   make init PROJECT_ID=my-proj REGION=us-central1
#
# Notes:
# - This target does NOT create projects or enable billing.
# - This target does NOT run Terraform; it only configures gcloud defaults and prints next steps.
# - If you switch gcloud configs in this command, re-run your next make command in a fresh invocation.
init:
	@command -v gcloud >/dev/null 2>&1 || (echo "Missing dependency: gcloud (https://cloud.google.com/sdk/docs/install)"; exit 1)
	@set -e; \
	  echo "== Init: configure gcloud defaults =="; \
	  if [ -n "$(GCLOUD_CONFIG)" ]; then \
	    if gcloud config configurations describe "$(GCLOUD_CONFIG)" >/dev/null 2>&1; then :; else \
	      echo "Creating gcloud configuration: $(GCLOUD_CONFIG)"; \
	      gcloud config configurations create "$(GCLOUD_CONFIG)" >/dev/null; \
	    fi; \
	    echo "Activating gcloud configuration: $(GCLOUD_CONFIG)"; \
	    gcloud config configurations activate "$(GCLOUD_CONFIG)" >/dev/null; \
	  fi; \
	  proj="$(PROJECT_ID)"; \
	  if [ -z "$$proj" ]; then proj=$$(gcloud config get-value project 2>/dev/null || true); fi; \
	  region="$(REGION)"; \
	  if [ -z "$$proj" ]; then \
	    echo "ERROR: PROJECT_ID is not set."; \
	    echo "Fix: run 'make init PROJECT_ID=<your-project-id> REGION=<region>'"; \
	    exit 1; \
	  fi; \
	  echo "Setting gcloud defaults..."; \
	  gcloud config set project "$$proj" >/dev/null; \
	  gcloud config set run/region "$$region" >/dev/null; \
	  active=$$(gcloud config configurations list --filter=is_active:true --format='value(name)' 2>/dev/null | head -n1); \
	  echo ""; \
	  echo "Configured:"; \
	  echo "  project: $$proj"; \
	  echo "  region:  $$region"; \
	  echo "  gcloud config: $${active:-default}"; \
	  echo ""; \
	  acct=$$(gcloud auth list --filter=status:ACTIVE --format='value(account)' 2>/dev/null | head -n1 || true); \
	  if [ -z "$$acct" ]; then \
	    echo "Auth status: not logged in"; \
	    echo "Next: make auth"; \
	  else \
	    echo "Auth status: $$acct"; \
	  fi; \
	  echo ""; \
	  echo "Next steps (GCP examples lane):"; \
	  echo "  make doctor-gcp"; \
	  echo "  make bootstrap-state"; \
	  echo "  make example-plan EXAMPLE=cloud_run_demo"; \
	  echo ""; \
	  echo "Tip: if you changed gcloud configs, run the next make command in a fresh invocation."

# Interactive auth helper (explicit on purpose).
# This will open browser windows for OAuth flows.
auth:
	@command -v gcloud >/dev/null 2>&1 || (echo "Missing dependency: gcloud"; exit 1)
	@echo "This will open a browser window for gcloud login + ADC."
	gcloud auth login
	gcloud auth application-default login

# Minimal local check (no gcloud required).
# -----------------------------
# Doctor (prerequisite checks)
# -----------------------------
# `make doctor` is the preferred first step for teammates.
#
# This repo is IaC-focused, so the "required" bar is small:
# - terraform is required
#
# Everything else is optional for local use, but recommended because CI will run these checks:
# - tflint, tfsec, checkov, conftest
doctor:
	@set -e; \
	fail=0; \
	echo "== Doctor: Terraform GCP Platform Baseline =="; \
	echo ""; \
	echo "Required:"; \
	if command -v terraform >/dev/null 2>&1; then \
	  echo "  ✓ terraform: $$(terraform version | head -n1)"; \
	else \
	  echo "  ✗ terraform not found. Install: https://developer.hashicorp.com/terraform/downloads"; \
	  fail=1; \
	fi; \
	echo ""; \
	echo "Recommended (CI uses these; optional locally):"; \
	if command -v tflint >/dev/null 2>&1; then echo "  ✓ tflint: $$(tflint --version | head -n1)"; else echo "  ⚠ tflint not found (install: brew install tflint)"; fi; \
	if command -v tfsec >/dev/null 2>&1; then echo "  ✓ tfsec: $$(tfsec --version 2>/dev/null | head -n1)"; else echo "  ⚠ tfsec not found (install: brew install tfsec)"; fi; \
	if command -v checkov >/dev/null 2>&1; then echo "  ✓ checkov: $$(checkov --version 2>/dev/null | head -n1)"; else echo "  ⚠ checkov not found (install: pipx install checkov)"; fi; \
	if command -v conftest >/dev/null 2>&1; then echo "  ✓ conftest: $$(conftest --version 2>/dev/null | head -n1)"; else echo "  ⚠ conftest not found (install: brew install conftest)"; fi; \
	echo ""; \
	echo "GCP tooling (only needed for example deploys):"; \
	if command -v gcloud >/dev/null 2>&1; then echo "  ✓ gcloud: $$(gcloud --version 2>/dev/null | head -n1)"; else echo "  ⚠ gcloud not found (install: https://cloud.google.com/sdk/docs/install)"; fi; \
	echo ""; \
	if [ "$$fail" -ne 0 ]; then \
	  echo "Doctor failed: terraform is required."; \
	  exit $$fail; \
	fi; \
	echo "Doctor OK."
# GCP-aware check for example deploys (remote state workflows).
doctor-gcp:
	@set -e; \
	fail=0; \
	echo "== Doctor: Terraform GCP Platform Baseline (GCP) =="; \
	echo ""; \
	echo "Resolved config (override with VAR=...):"; \
	echo "  PROJECT_ID=$(PROJECT_ID)"; \
	echo "  REGION=$(REGION)"; \
	echo "  EXAMPLE=$(EXAMPLE)"; \
	echo "  TF_STATE_BUCKET=$(TF_STATE_BUCKET)"; \
	echo "  TF_STATE_PREFIX=$(TF_STATE_PREFIX)"; \
	echo ""; \
	echo "Required for example deploys:"; \
	if command -v gcloud >/dev/null 2>&1; then \
	  echo "  ✓ gcloud: $$(gcloud --version 2>/dev/null | head -n1)"; \
	else \
	  echo "  ✗ gcloud not found. Install: https://cloud.google.com/sdk/docs/install"; \
	  fail=1; \
	fi; \
	if command -v terraform >/dev/null 2>&1; then \
	  echo "  ✓ terraform: $$(terraform version | head -n1)"; \
	else \
	  echo "  ✗ terraform not found. Install: https://developer.hashicorp.com/terraform/downloads"; \
	  fail=1; \
	fi; \
	if [ -z "$(PROJECT_ID)" ]; then \
	  echo "  ✗ gcloud project not set. Run: gcloud config set project <PROJECT_ID>"; \
	  fail=1; \
	else \
	  echo "  ✓ gcloud project set"; \
	fi; \
	if [ -z "$(REGION)" ]; then \
	  echo "  ⚠ gcloud run/region not set. Recommended: gcloud config set run/region us-central1"; \
	else \
	  echo "  ✓ gcloud run/region: $(REGION)"; \
	fi; \
	if command -v gcloud >/dev/null 2>&1; then \
	  acct=$$(gcloud auth list --filter=status:ACTIVE --format='value(account)' 2>/dev/null | head -n1); \
	  if [ -n "$$acct" ]; then \
	    echo "  ✓ gcloud user auth: $$acct"; \
	  else \
	    echo "  ⚠ gcloud user not authenticated. Run: gcloud auth login"; \
	  fi; \
	  if gcloud auth application-default print-access-token >/dev/null 2>&1; then \
	    echo "  ✓ ADC credentials: OK"; \
	  else \
	    echo "  ⚠ ADC not configured. Run: gcloud auth application-default login"; \
	  fi; \
	fi; \
	echo ""; \
	if [ "$$fail" -ne 0 ]; then \
	  echo "Doctor failed: fix missing items above, then re-run."; \
	  exit $$fail; \
	fi; \
	echo "Doctor OK."
fmt:
	terraform fmt -recursive

# Validate root + all examples without requiring backend config.
# This is what CI does as well.
validate: doctor
	@echo "Validating root..."
	terraform init -backend=false >/dev/null
	terraform validate
	@for d in examples/*; do \
		if [ -d "$$d" ]; then \
			echo "Validating $$d"; \
			(cd "$$d" && terraform init -backend=false >/dev/null && terraform validate); \
		fi; \
	done

# -----------------------------
# Remote state bootstrap
# -----------------------------
bootstrap-state: doctor-gcp
	@echo "Ensuring tfstate bucket exists: gs://$(TF_STATE_BUCKET)"
	@if gcloud storage buckets describe "gs://$(TF_STATE_BUCKET)" >/dev/null 2>&1; then \
		echo "Bucket already exists."; \
	else \
		echo "Creating bucket..."; \
		gcloud storage buckets create "gs://$(TF_STATE_BUCKET)" --location="$(REGION)" --uniform-bucket-level-access --public-access-prevention=enforced; \
		echo "Enabling versioning..."; \
		gcloud storage buckets update "gs://$(TF_STATE_BUCKET)" --versioning; \
	fi

# -----------------------------
# Example workflows (remote state)
# -----------------------------
example-init: doctor-gcp bootstrap-state
	@test -d "$(EXAMPLE_DIR)" || (echo "Example not found: $(EXAMPLE_DIR)"; exit 1)
	terraform -chdir=$(EXAMPLE_DIR) init -reconfigure \
		-backend-config="bucket=$(TF_STATE_BUCKET)" \
		-backend-config="prefix=$(TF_STATE_PREFIX)"

example-plan: example-init
	terraform -chdir=$(EXAMPLE_DIR) plan \
		-var "project_id=$(PROJECT_ID)" \
		$(EXTRA_VARS)

example-apply: example-init
	terraform -chdir=$(EXAMPLE_DIR) apply -auto-approve \
		-var "project_id=$(PROJECT_ID)" \
		$(EXTRA_VARS)

example-destroy: example-init
	terraform -chdir=$(EXAMPLE_DIR) destroy -auto-approve \
		-var "project_id=$(PROJECT_ID)" \
		$(EXTRA_VARS)

# -----------------------------
# Lint / security scan hooks
# -----------------------------

# tflint typically requires the google ruleset plugin.
# In CI we install it via GitHub Actions. Locally, install tflint first.
tflint:
	$(call require,tflint)
	tflint --recursive

tfsec:
	$(call require,tfsec)
	tfsec . --exclude-downloaded-modules

checkov:
	$(call require,checkov)
	checkov -d . --quiet

conftest:
	$(call require,conftest)
	conftest test --parser hcl2 -p policy .

scan: tfsec checkov conftest
	@echo "OK: scan passed"
