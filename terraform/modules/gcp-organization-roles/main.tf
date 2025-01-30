resource "google_organization_iam_member" "this" {
  for_each = toset(var.roles)

  org_id = var.organization_id
  role   = each.value
  member = "serviceAccount:${var.service_account_email}"
}
