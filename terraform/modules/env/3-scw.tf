resource "scaleway_account_project" "this" {
  name = var.scw.project
}
resource "scaleway_iam_application" "this" {
  name = var.scw.project
}
resource "scaleway_iam_group_membership" "this" {
  application_id = scaleway_iam_application.this.id

  group_id = data.scaleway_iam_group.admins.id
}
resource "scaleway_iam_api_key" "this" {
  application_id = scaleway_iam_application.this.id
}
