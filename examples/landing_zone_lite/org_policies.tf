// Optional org policy posture.
//
// NOTE: these resources require the caller to have Org Policy Admin permissions on the project.
// Many personal GCP projects won't have this; keep `enable_org_policies=false` for those.

resource "google_project_organization_policy" "disable_sa_key_creation" {
  count      = var.enable_org_policies ? 1 : 0
  project    = var.project_id
  constraint = "constraints/iam.disableServiceAccountKeyCreation"

  boolean_policy {
    enforced = true
  }
}

resource "google_project_organization_policy" "disable_sa_key_upload" {
  count      = var.enable_org_policies ? 1 : 0
  project    = var.project_id
  constraint = "constraints/iam.disableServiceAccountKeyUpload"

  boolean_policy {
    enforced = true
  }
}
