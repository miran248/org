# The 14 public repos that the bootstrap workspace adopts from GitHub.
# Every value below is the live snapshot recorded in
# docs/specs/github-repo-governance.md, so importing a repo and the following
# plan move no field except the merge policy in the resource body.
locals {
  public_repos = {
    abortable = {
      description      = "Provides abortable asynchronous primitives, based on promises"
      homepage_url     = ""
      topics           = ["abortable", "javascript", "promise"]
      allow_auto_merge = false
      has_issues       = true
      has_projects     = true
      has_wiki         = true
    }
    babel-test = {
      description      = "webpack + babel + yarn workspaces = kaboom"
      homepage_url     = ""
      topics           = ["babel7", "webpack4", "yarn"]
      allow_auto_merge = false
      has_issues       = true
      has_projects     = true
      has_wiki         = true
    }
    css-blend-mode-test = {
      description      = ""
      homepage_url     = "https://miran248.github.io/css-blend-mode-test/"
      topics           = ["blend-modes", "flexbox", "gallery", "react", "styled-components"]
      allow_auto_merge = false
      has_issues       = true
      has_projects     = true
      has_wiki         = false
    }
    cuttlebelle-test = {
      description      = ""
      homepage_url     = "https://miran248.github.io/cuttlebelle-test/"
      topics           = ["cuttlebelle", "markdown-it", "template"]
      allow_auto_merge = false
      has_issues       = true
      has_projects     = true
      has_wiki         = true
    }
    dotfiles-macos = {
      description      = ""
      homepage_url     = ""
      topics           = []
      allow_auto_merge = false
      has_issues       = true
      has_projects     = true
      has_wiki         = true
    }
    dydx-v4-test = {
      description      = ""
      homepage_url     = ""
      topics           = []
      allow_auto_merge = false
      has_issues       = true
      has_projects     = true
      has_wiki         = true
    }
    envs = {
      description      = ""
      homepage_url     = ""
      topics           = ["ansible", "dotfiles"]
      allow_auto_merge = false
      has_issues       = true
      has_projects     = true
      has_wiki         = true
    }
    fets-response-status-repro = {
      description      = "A repro repo for a bug report."
      homepage_url     = "https://github.com/ardatan/feTS/issues/479"
      topics           = []
      allow_auto_merge = false
      has_issues       = true
      has_projects     = true
      has_wiki         = true
    }
    multica-sandbox = {
      description      = "Per-epic sandbox environments for Multica work: one Docker Compose project per epic, a project .multica/compose.yaml with its x-msbx block, stable assigned loopback ports and msbx.test names"
      homepage_url     = ""
      topics           = []
      allow_auto_merge = false
      has_issues       = true
      has_projects     = true
      has_wiki         = false
    }
    multica-workspace = {
      description      = "Anonymous, stateless Multica agent catalog: roles, skills, workflows and a by-name sync."
      homepage_url     = ""
      topics           = []
      allow_auto_merge = false
      has_issues       = true
      has_projects     = true
      has_wiki         = true
    }
    protoactor-remote-test = {
      description      = "protoactor remote api playground"
      homepage_url     = ""
      topics           = []
      allow_auto_merge = false
      has_issues       = true
      has_projects     = true
      has_wiki         = true
    }
    roarfest = {
      description      = "roarfest page"
      homepage_url     = "https://roarfest.si"
      topics           = []
      allow_auto_merge = false
      has_issues       = false
      has_projects     = true
      has_wiki         = false
    }
    terra = {
      description      = "3D spherical-planet procedural world experiment"
      homepage_url     = ""
      topics           = []
      allow_auto_merge = false
      has_issues       = true
      has_projects     = true
      has_wiki         = false
    }
    text-twister = {
      description      = "react + redux game"
      homepage_url     = "https://miran248.github.io/text-twister/"
      topics           = ["babel7", "docker-compose", "formik", "monorepo", "protobuf", "react", "redux", "redux-logic", "styled-components", "travis-ci", "webpack4"]
      allow_auto_merge = false
      has_issues       = true
      has_projects     = false
      has_wiki         = false
    }
  }
}

resource "github_repository" "public" {
  for_each = local.public_repos

  name         = each.key
  description  = each.value.description
  homepage_url = each.value.homepage_url
  topics       = each.value.topics
  visibility   = "public"
  auto_init    = false

  allow_auto_merge       = each.value.allow_auto_merge
  allow_squash_merge     = true
  allow_merge_commit     = false
  allow_rebase_merge     = false
  delete_branch_on_merge = true

  has_issues   = each.value.has_issues
  has_projects = each.value.has_projects
  has_wiki     = each.value.has_wiki

  # Pages is out of the snapshot, so importing a repo must not drop its site
  # (4 of the 16 publish from gh-pages or the default branch).
  lifecycle {
    ignore_changes = [pages]
  }
}

import {
  for_each = local.public_repos

  to = github_repository.public[each.key]
  id = each.key
}
