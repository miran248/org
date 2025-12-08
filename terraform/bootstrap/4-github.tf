# TODO: limit to a set of projects
# TODO: generate unique token per project
resource "google_secret_manager_secret" "github" {
  for_each = google_project.this

  project = each.value.project_id

  secret_id = "github"

  replication {
    auto {
    }
  }
}
resource "google_secret_manager_secret_version" "github" {
  for_each = google_secret_manager_secret.github

  secret      = each.value.id
  secret_data = local.tokens.github
}
