locals {
  github_token = data.google_secret_manager_secret_version.github_token.secret_data
  scaleway     = jsondecode(data.google_secret_manager_secret_version.scaleway.secret_data)

  s0 = {
    gcp = {
      services = [
        "dns.googleapis.com",
        "secretmanager.googleapis.com",
        "serviceusage.googleapis.com",

        # required by oidc-tfc
        "cloudresourcemanager.googleapis.com",
        "iam.googleapis.com",
        "iamcredentials.googleapis.com",
        "sts.googleapis.com",
      ]
      roles = [
        "roles/dns.admin",
        "roles/secretmanager.admin",

        # required by oidc-tfc
        "roles/iam.securityAdmin",
        "roles/iam.serviceAccountAdmin",
        "roles/iam.serviceAccountKeyAdmin",
        "roles/iam.workloadIdentityPoolAdmin",
      ]
    }
  }
  s1 = {
    envs = [
      {
        key   = "miran248-org-bootstrap"
        owned = true
        gcp = {
          project  = "miran248-org-bootstrap"
          services = flatten([local.s0.gcp.services, "admin.googleapis.com", "cloudbilling.googleapis.com"])
          org_roles = [
            "roles/billing.user",
            "roles/dns.admin",
            "roles/resourcemanager.organizationAdmin",
            "roles/secretmanager.admin",
            "roles/serviceusage.serviceUsageAdmin",

            "roles/iam.securityAdmin",
            "roles/iam.serviceAccountAdmin",
            "roles/iam.serviceAccountKeyAdmin",
            "roles/iam.workloadIdentityPoolAdmin",
          ]
          roles = flatten([local.s0.gcp.roles, "roles/editor"])
        }
        sw  = { project = "miran248-org-bootstrap" }
        tfc = { organization = "miran248", project = "org", workspace = "bootstrap", working_directory = "terraform/bootstrap" }
      },
      {
        key   = "miran248-terraform-talos-modules-dev"
        owned = true
        gcp = {
          project   = "miran248-talos-modules-dev"
          services  = flatten([local.s0.gcp.services, "storage-api.googleapis.com"])
          org_roles = ["roles/resourcemanager.folderAdmin", "roles/resourcemanager.organizationViewer"]
          roles     = flatten([local.s0.gcp.roles, "roles/storage.admin"])
        }
        sw  = { project = "miran248-terraform-talos-modules-dev" }
        tfc = { organization = "miran248", project = "terraform-talos-modules", workspace = "dev", working_directory = "dev" }
      },
    ]
  }
  s2 = {
    envs = [for env in local.s1.envs : merge(env, {
      tfc = merge(env.tfc, {
        oidc = "organization:${env.tfc.organization}:project:${env.tfc.project}:workspace:${env.tfc.workspace}"
      })
      # TODO: remove and use env.key instead
      keys = {
        gcp = {
          project = env.gcp.project
        }
        sw = {
          project = env.sw.project
        }
        tfc = {
          organization = env.tfc.organization
          project      = join("-", [env.tfc.organization, env.tfc.project])
          workspace    = join("-", [env.tfc.organization, env.tfc.project, env.tfc.workspace])
        }
      }
    })]
  }

  gcp = {
    projects = { for env in local.s2.envs : env.keys.gcp.project => env }
  }
  sw = {
    projects = { for env in local.s2.envs : env.keys.sw.project => env }
  }
  tfc = {
    organizations = merge([for env in local.s2.envs : { "${env.keys.tfc.organization}" = env }]...)
    projects      = merge([for env in local.s2.envs : { "${env.keys.tfc.project}" = env }]...)
    workspaces    = merge([for env in local.s2.envs : { "${env.keys.tfc.workspace}" = env }]...)
  }

  google_projects = { for key, env in local.gcp.projects : key => env.owned ? google_project.this[key] : data.google_project.this[key] }
  tfe_workspaces  = { for key, env in local.tfc.workspaces : key => env.owned ? tfe_workspace.this[key] : data.tfe_workspace.this[key] }
}
