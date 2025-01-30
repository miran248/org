resource "google_project_iam_member" "this" {
  for_each = toset(var.roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${var.service_account_email}"
}
