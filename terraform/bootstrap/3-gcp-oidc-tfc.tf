# resource "google_iam_workload_identity_pool" "oidc_tfc" {
#   for_each = { for key, env in local.gcp.projects : key => env if env.owned }

#   project = local.google_projects[each.key].project_id

#   workload_identity_pool_id = "terraform"
# }
moved {
  from = google_iam_workload_identity_pool.oidc_tfc["miran248-talos-modules-dev"]
  to   = module.miran248-terraform-talos-modules-dev.google_iam_workload_identity_pool.oidc_tfc
}
# resource "google_iam_workload_identity_pool_provider" "oidc_tfc" {
#   for_each = { for key, env in local.gcp.projects : key => env if env.owned }

#   project = local.google_projects[each.key].project_id

#   workload_identity_pool_id          = google_iam_workload_identity_pool.oidc_tfc[each.key].workload_identity_pool_id
#   workload_identity_pool_provider_id = "terraform-oidc"

#   attribute_mapping = {
#     "google.subject" = "assertion.sub"
#     "attribute.aud"  = "assertion.aud"
#   }
#   attribute_condition = "assertion.sub.startsWith(\"${each.value.tfc.oidc}\")"

#   oidc {
#     issuer_uri = "https://app.terraform.io"
#   }
# }
moved {
  from = google_iam_workload_identity_pool_provider.oidc_tfc["miran248-talos-modules-dev"]
  to   = module.miran248-terraform-talos-modules-dev.google_iam_workload_identity_pool_provider.oidc_tfc
}

# resource "google_service_account" "oidc_tfc" {
#   for_each = { for key, env in local.gcp.projects : key => env if env.owned }

#   project = local.google_projects[each.key].project_id

#   account_id = "terraform"
# }
moved {
  from = google_service_account.oidc_tfc["miran248-talos-modules-dev"]
  to   = module.miran248-terraform-talos-modules-dev.google_service_account.oidc_tfc
}
# resource "google_service_account_iam_member" "oidc_tfc" {
#   for_each = { for key, env in local.gcp.projects : key => env if env.owned }

#   service_account_id = google_service_account.oidc_tfc[each.key].id
#   role               = "roles/iam.workloadIdentityUser"
#   member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.oidc_tfc[each.key].name}/*"
# }
moved {
  from = google_service_account_iam_member.oidc_tfc["miran248-talos-modules-dev"]
  to   = module.miran248-terraform-talos-modules-dev.google_service_account_iam_member.oidc_tfc
}

# module "oidc_tfc" {
#   for_each = { for key, env in local.tfc.workspaces : key => env if env.owned }

#   source = "../modules/gcp-oidc-tfc"

#   tfc_workspace_id = local.tfe_workspaces[each.key].id

#   gcp_pool_provider_name    = google_iam_workload_identity_pool_provider.oidc_tfc[each.value.keys.gcp.project].name
#   gcp_service_account_email = google_service_account.oidc_tfc[each.value.keys.gcp.project].email
# }
moved {
  from = module.oidc_tfc["miran248-terraform-talos-modules-dev"].tfe_variable.enable_gcp_provider_auth
  to   = module.miran248-terraform-talos-modules-dev.tfe_variable.enable_gcp_provider_auth
}
moved {
  from = module.oidc_tfc["miran248-terraform-talos-modules-dev"].tfe_variable.gcp_workload_provider_name
  to   = module.miran248-terraform-talos-modules-dev.tfe_variable.gcp_workload_provider_name
}
moved {
  from = module.oidc_tfc["miran248-terraform-talos-modules-dev"].tfe_variable.gcp_service_account_email
  to   = module.miran248-terraform-talos-modules-dev.tfe_variable.gcp_service_account_email
}
