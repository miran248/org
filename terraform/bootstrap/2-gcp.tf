# resource "google_project" "this" {
#   for_each = { for key, env in local.gcp.projects : key => env if env.owned }

#   org_id          = data.google_organization.this.org_id
#   billing_account = data.google_billing_account.this.id
#   project_id      = each.value.gcp.project
#   name            = each.value.gcp.project

#   deletion_policy = "DELETE"
# }
moved {
  from = google_project.this["miran248-talos-modules-dev"]
  to   = module.miran248-terraform-talos-modules-dev.google_project.this
}

# module "project_services" {
#   for_each = { for key, env in local.gcp.projects : key => env if env.owned }

#   source = "../modules/gcp-project-services"

#   project_id = local.google_projects[each.value.keys.gcp.project].project_id

#   services = each.value.gcp.services
# }
moved {
  from = module.project_services["miran248-talos-modules-dev"].google_project_service.this
  to   = module.miran248-terraform-talos-modules-dev.google_project_service.this
}
# module "organization_roles" {
#   for_each = { for key, env in local.gcp.projects : key => env if env.owned }

#   source = "../modules/gcp-organization-roles"

#   organization_id       = data.google_organization.this.org_id
#   service_account_email = google_service_account.oidc_tfc[each.value.keys.gcp.project].email

#   roles = each.value.gcp.org_roles
# }
moved {
  from = module.organization_roles["miran248-talos-modules-dev"].google_organization_iam_member.this
  to   = module.miran248-terraform-talos-modules-dev.google_organization_iam_member.oidc_tfc
}
# module "project_roles" {
#   for_each = { for key, env in local.gcp.projects : key => env if env.owned }

#   source = "../modules/gcp-project-roles"

#   project_id            = local.google_projects[each.value.keys.gcp.project].project_id
#   service_account_email = google_service_account.oidc_tfc[each.value.keys.gcp.project].email

#   roles = each.value.gcp.roles
# }
moved {
  from = module.project_roles["miran248-talos-modules-dev"].google_project_iam_member.this
  to   = module.miran248-terraform-talos-modules-dev.google_project_iam_member.oidc_tfc
}
