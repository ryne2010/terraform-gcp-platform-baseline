config {
  # Scan modules and examples.
  call_module_type = "all"
  force            = false
  disabled_by_default = false
}

# Google ruleset (installs via `tflint --init`)
plugin "google" {
  enabled = true
  version = "0.33.0"
  source  = "github.com/terraform-linters/tflint-ruleset-google"
}
