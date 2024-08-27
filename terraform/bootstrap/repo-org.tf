resource "github_repository" "this" {
  name        = "org"
  description = "manages repos and other github related stuff"

  allow_auto_merge       = true
  allow_merge_commit     = true
  allow_squash_merge     = false
  allow_rebase_merge     = false
  auto_init              = false
  delete_branch_on_merge = false
  has_issues             = true
  has_projects           = false
  has_wiki               = false
  visibility             = "public"

  topics = [
    "terraform",
    "github",
  ]
}
