resource "scaleway_account_project" "this" {
  for_each = { for key, env in local.scaleway.projects : key => env if env.owned }

  name = each.value.scaleway.project
}
resource "scaleway_iam_application" "this" {
  for_each = scaleway_account_project.this

  name = each.value.name
}
resource "scaleway_iam_group_membership" "this" {
  for_each = scaleway_iam_application.this

  application_id = each.value.id

  group_id = data.scaleway_iam_group.admins.id
}
resource "scaleway_iam_api_key" "this" {
  for_each = scaleway_iam_application.this

  application_id = each.value.id
}

resource "google_secret_manager_secret" "scaleway" {
  for_each = google_project.this

  project = each.value.project_id

  secret_id = "scaleway"

  replication {
    auto {
    }
  }
}
resource "google_secret_manager_secret_version" "scaleway" {
  for_each = google_secret_manager_secret.scaleway

  secret = each.value.id

  secret_data = jsonencode({
    organization_id = local.tokens.scaleway.organization_id
    project_id      = scaleway_account_project.this[local.gcp.projects[each.key].keys.scaleway.project].id
    access_key      = scaleway_iam_api_key.this[local.gcp.projects[each.key].keys.scaleway.project].access_key
    secret_key      = scaleway_iam_api_key.this[local.gcp.projects[each.key].keys.scaleway.project].secret_key
  })
}
