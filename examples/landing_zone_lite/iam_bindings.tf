# Baseline IAM patterns (Google Groups)
#
# This example demonstrates a "landing zone lite" approach:
# - standard platform roles are granted via Google Groups
# - app repos can grant app-specific roles via app-prefixed groups
#
# If you don't have a Google Workspace domain (or don't want Terraform to manage IAM), leave
# `workspace_domain` empty and this file becomes a no-op.

locals {
  workspace_enabled = var.workspace_domain != ""

  groups = local.workspace_enabled ? {
    platform_admins    = "group:${var.group_prefix}-platform-admins@${var.workspace_domain}"
    platform_engineers = "group:${var.group_prefix}-platform-engineers@${var.workspace_domain}"
    platform_auditors  = "group:${var.group_prefix}-auditors@${var.workspace_domain}"
  } : {}

  project_iam_members = local.workspace_enabled ? {
    # Platform admins: can operate IAM + services + observe.
    "platform_admins_project_iam_admin"  = { role = "roles/resourcemanager.projectIamAdmin", member = local.groups.platform_admins }
    "platform_admins_serviceusage_admin" = { role = "roles/serviceusage.serviceUsageAdmin", member = local.groups.platform_admins }
    "platform_admins_logging_admin"      = { role = "roles/logging.admin", member = local.groups.platform_admins }
    "platform_admins_monitoring_admin"   = { role = "roles/monitoring.admin", member = local.groups.platform_admins }

    # Platform engineers: read-only observability + inventory.
    "platform_engineers_logging_viewer"      = { role = "roles/logging.viewer", member = local.groups.platform_engineers }
    "platform_engineers_monitoring_viewer"   = { role = "roles/monitoring.viewer", member = local.groups.platform_engineers }
    "platform_engineers_serviceusage_viewer" = { role = "roles/serviceusage.serviceUsageViewer", member = local.groups.platform_engineers }

    # Auditors: IAM review + read-only observability.
    "platform_auditors_iam_security_reviewer" = { role = "roles/iam.securityReviewer", member = local.groups.platform_auditors }
    "platform_auditors_logging_viewer"        = { role = "roles/logging.viewer", member = local.groups.platform_auditors }
    "platform_auditors_monitoring_viewer"     = { role = "roles/monitoring.viewer", member = local.groups.platform_auditors }
  } : {}
}

resource "google_project_iam_member" "workspace" {
  for_each = local.project_iam_members

  project = var.project_id
  role    = each.value.role
  member  = each.value.member
}
