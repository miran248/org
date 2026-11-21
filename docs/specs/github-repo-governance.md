integration: spec/MIR-277

## Problem Statement

`miran248` owns 44 GitHub repositories under a user account (the repository named `org` is a repository, not an organization). 32 of them are active — 16 public and 16 private — while 9 are forks and 3 are archived. Only `multica-workspace` currently deletes its head branch on merge; the other 31 keep every merged branch forever. Every active repo accepts merge commits and rebase merges alongside squash merges. Only `org` and `terraform-talos-modules` are managed by Terraform, so the settings of the other 30 repos exist only as GitHub UI drift: a change is invisible, unaudited and unenforced.

A fresh audit of the 32 active repos on 2026-11-21 found 68 branches: 12 are merged and should be gone, 16 are open-PR heads that must stay, and the rest is unmerged work that nobody asked to delete. Across all owned repos there are 17 open PRs; the 17th sits in the archived `factory-probe-01bf35` and is untouchable. The 19 private repos are on GitHub Free, so branch protection and rulesets are unavailable (HTTP 403); the archived repos are hard read-only (a no-op PATCH returns 403).

## Solution

One Terraform-owned policy covers all 32 active repos: squash-only merges with delete-on-merge, and every other setting preserved as an explicit snapshot of today's value. The 16 public repos stay in the existing `bootstrap` workspace. The 16 private repos move to a new private repository, `org-private`, whose Terraform root runs in a new `private` TFC workspace in the existing `org` project. The 12 merged branches are deleted once — after a dry run, with a full-SHA report and a documented restore path — while every PR head that is still open at cleanup time, the 9 forks and the 3 archived repos are left exactly as they are.

## User Stories

1. As the account owner, I want every active repo to delete its head branch on merge, so that branch lists show live work only.
2. As the account owner, I want every active repo to be squash-only, so that history stays linear and predictable.
3. As the account owner, I want auto-merge, issues, projects, wiki, description, homepage and topics to keep their current values, so that adopting Terraform does not silently change the repos.
4. As the account owner, I want those values written down in the spec, so that UI drift becomes reviewable.
5. As the account owner, I want the 32 active repos split into public and private Terraform roots, so that a private repo's policy never depends on a public repository's workspace.
6. As the account owner, I want the private root to run in the existing `org` TFC project, so that the slice needs no new Terraform Cloud organization or GCP project.
7. As the account owner, I want the GitHub token supplied as a sensitive workspace variable, so that no credential lives in the private repository.
8. As the account owner, I want the 30 existing repos imported rather than recreated, so that bring-up proposes no destroy or replace.
9. As the account owner, I want the imports to adopt the exact settings in the repo maps, so that the first plan after import is meaningful.
10. As the account owner, I want a clean Terraform plan after apply on both roots, so that the code and the live state agree.
11. As the account owner, I want the 12 merged branches deleted, so that repositories with merged work stop showing dead branches.
12. As the account owner, I want a dry run that compares the live branches against the recorded SHAs before anything is deleted, so that the cleanup cannot widen its scope.
13. As the account owner, I want the full head SHA of every deleted branch recorded on the delivery ticket, so that each one can be restored.
14. As the account owner, I want the 17 open-PR heads untouched, so that in-flight work keeps its branches.
15. As the account owner, I want an open PR whose base branch is deleted to be preserved, so that the cleanup does not silently close reviewable work.
16. As the account owner, I want the 9 forks and 3 archived repos untouched, so that upstream mirrors and read-only history are not disturbed.
17. As the account owner, I want a one-command restore per deleted branch, so that a mistaken deletion is recoverable.
18. As the account owner, I want the release to verify the policy through the GitHub API, so that the proof is the live state, not Terraform's opinion of it.
19. As the account owner, I want the release to verify that the 12 branches are gone and the 17 open-PR heads remain, so that both halves of the cleanup are proven.
20. As the account owner, I want the release to verify that `org-private` is private and its `private` workspace exists with the right working directory, so that the private half is actually deployed.
21. As the account owner, I want no branch protection or rulesets, so that this slice does not depend on a GitHub paid plan.
22. As the account owner, I want no committed audit or cleanup tooling, so that the repository stays a policy repository.
23. As the account owner, I want each repository to keep its own release cycle, so that this slice stays independent of the release-please work.
24. As a reviewer, I want the proposed breakdown in the spec to match the published children exactly, so that the merge approves a set I can see.

## Implementation Decisions

### Scope and target policy

An **active repo** is a repository owned by `miran248` that is neither a fork nor archived. The audit found 44 owned repos: 32 active, 9 forks and 3 archived. Forks are upstream mirrors; archived repos are read-only. Both are excluded from the maps and are never patched, imported or deleted from. The excluded forks are `Zenject`, `coroot-operator`, `cuttlebelle`, `multica`, `postgres-operator`, `react-native-pincode`, `restate-operator`, `talos` and `terraform-aws-cognito-user-pool`; the archived repos are `agent-config`, `factory-probe-01bf35` and `stress-fixture`.

Every one of the 32 active repos gets the same merge policy:

- `allow_squash_merge` true
- `allow_merge_commit` false
- `allow_rebase_merge` false
- `delete_branch_on_merge` true

Everything else keeps its current value, that is: visibility, `allow_auto_merge`, description, homepage, topics, issues, projects and wiki. There is no branch protection and no ruleset, because the private repos are on GitHub Free. There is no new GCP project and `modules/env` is not used.

For `org` and `terraform-talos-modules` the change flips squash on, merge-commit off and delete-on-merge on, and their existing `allow_auto_merge = true` stays; their existing resource blocks remain and only these policy fields change, except one snapshot correction: `terraform/bootstrap/terraform-talos-modules.tf` still carries the old description "a collection of opinionated terraform modules for running talos on hetzner" while live (and the table below) reads "Kubernetes the hard way, automated with Terraform and Talos", so the change set corrects that description too. Without it, stage-2 apply overwrites the live description and release verification fails.

### Repo maps

These are the current values from the fresh audit. The target policy above applies to every row; every other column is preserved as written.

#### Public — 16 repos

| Repo | Default | Squash | Merge commit | Rebase | Auto-merge | Delete on merge | Issues | Projects | Wiki | Description | Homepage | Topics |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `abortable` | `master` | yes | yes | yes | no | no | yes | yes | yes | Provides abortable asynchronous primitives, based on promises | — | abortable, javascript, promise |
| `babel-test` | `master` | yes | yes | yes | no | no | yes | yes | yes | webpack + babel + yarn workspaces = kaboom | — | babel7, webpack4, yarn |
| `css-blend-mode-test` | `master` | yes | yes | yes | no | no | yes | yes | no | — | https://miran248.github.io/css-blend-mode-test/ | blend-modes, flexbox, gallery, react, styled-components |
| `cuttlebelle-test` | `master` | yes | yes | yes | no | no | yes | yes | yes | — | https://miran248.github.io/cuttlebelle-test/ | cuttlebelle, markdown-it, template |
| `dotfiles-macos` | `master` | yes | yes | yes | no | no | yes | yes | yes | — | — | — |
| `dydx-v4-test` | `main` | yes | yes | yes | no | no | yes | yes | yes | — | — | — |
| `envs` | `master` | yes | yes | yes | no | no | yes | yes | yes | — | — | ansible, dotfiles |
| `fets-response-status-repro` | `main` | yes | yes | yes | no | no | yes | yes | yes | A repro repo for a bug report. | https://github.com/ardatan/feTS/issues/479 | — |
| `multica-sandbox` | `main` | yes | yes | yes | no | no | yes | yes | no | Per-epic sandbox environments for Multica work: one Docker Compose project per epic, a project .multica/compose.yaml with its x-msbx block, stable assigned loopback ports and msbx.test names | — | — |
| `multica-workspace` | `main` | yes | yes | yes | no | yes | yes | yes | yes | Anonymous, stateless Multica agent catalog: roles, skills, workflows and a by-name sync. | — | — |
| `org †` | `main` | no | yes | no | yes | no | yes | no | no | manages repos and other github related stuff | — | github, terraform |
| `protoactor-remote-test` | `main` | yes | yes | yes | no | no | yes | yes | yes | protoactor remote api playground | — | — |
| `roarfest` | `master` | yes | yes | yes | no | no | no | yes | no | roarfest page | https://roarfest.si | — |
| `terra` | `main` | yes | yes | yes | no | no | yes | yes | no | 3D spherical-planet procedural world experiment | — | — |
| `terraform-talos-modules †` | `main` | no | yes | no | yes | no | yes | no | no | Kubernetes the hard way, automated with Terraform and Talos | — | hetzner, modules, talos, terraform |
| `text-twister` | `master` | yes | yes | yes | no | no | yes | no | no | react + redux game | https://miran248.github.io/text-twister/ | babel7, docker-compose, formik, monorepo, protobuf, react, redux, redux-logic, styled-components, travis-ci, webpack4 |

#### Private — 16 repos

| Repo | Default | Squash | Merge commit | Rebase | Auto-merge | Delete on merge | Issues | Projects | Wiki | Description | Homepage | Topics |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `banke.si` | `master` | yes | yes | yes | no | no | yes | yes | no | — | — | — |
| `bnm` | `main` | yes | yes | yes | no | no | yes | yes | no | — | — | — |
| `cflow` | `master` | yes | yes | yes | no | no | yes | yes | no | — | — | — |
| `cflow.io` | `develop` | yes | yes | yes | no | no | yes | yes | no | — | — | — |
| `codespaces` | `main` | yes | yes | yes | no | no | yes | yes | no | — | — | — |
| `dev` | `main` | yes | yes | yes | no | no | yes | yes | no | — | — | — |
| `dotfiles` | `main` | yes | yes | yes | no | no | yes | yes | no | — | — | — |
| `dydx` | `main` | yes | yes | yes | no | no | yes | yes | no | — | — | — |
| `hermes-infra` | `main` | yes | yes | yes | no | no | yes | yes | no | — | — | — |
| `idler` | `main` | yes | yes | yes | no | no | yes | yes | no | — | — | — |
| `invaders` | `main` | yes | yes | yes | no | no | yes | yes | no | — | — | — |
| `llm` | `main` | yes | yes | yes | no | no | yes | yes | no | — | — | — |
| `miner` | `main` | yes | yes | yes | no | no | yes | yes | no | — | — | — |
| `niimbot` | `main` | yes | yes | yes | no | no | yes | yes | no | — | — | — |
| `stress-rig` | `main` | yes | yes | yes | no | no | yes | yes | no | Harness for the stress rig: frozen fixture ticket, hidden acceptance test, reference solution, driver and report | — | — |
| `take-lang` | `main` | yes | yes | yes | no | no | yes | yes | no | — | — | — |

† Already managed in the `bootstrap` workspace; its block stays and only the policy fields above change, plus the `terraform-talos-modules` description correction described above.

Visibility is fixed by the table: public rows are `public`, private rows are `private`. `multica-workspace` is the only active repo that already deletes on merge, and `org` / `terraform-talos-modules` are the only active repos with auto-merge enabled.

### Terraform split

**Public root — `terraform/bootstrap` in the `org` repository.** The workspace stays the existing `bootstrap` workspace in TFC organization `miran248`. The change set is: a new file holding a `for_each` map of the 14 public repos that are not yet imported, one resource per repo with every snapshot field explicit, each with an import block adopting the repo by name; the existing `org` and `terraform-talos-modules` blocks keep their place and only get the policy flip, with the `terraform-talos-modules` description corrected to its live value so no snapshot field moves; and a new file for the `org-private` repository, the `private` workspace and its token variable. Nothing else in the workspace changes — no GCP, DNS or `modules/env` resources are added.

**Private root — `terraform/` in the new `org-private` repository.** The repository is created by `bootstrap` as a private repo with squash-only, delete-on-merge, auto-init enabled (so `main` exists and can be the base of a branch), description "Terraform-owned policy for the private miran248 repositories", topics `terraform` and `github`, issues on, projects on, wiki off and auto-merge off. `bootstrap` also creates the `private` TFC workspace in the existing `org` project (`prj-beKuyN9ULjaJkZyT`), with working directory `terraform`, remote execution, Terraform version `latest`, auto-apply off and no VCS connection — the same run pattern the `bootstrap` workspace already uses. A sensitive `github_token` workspace variable is created on it from the same GCP secret the `bootstrap` provider reads, so the stage-3 run needs no manual secret and no token is committed.

The `org-private/terraform` layout is: a Terraform block selecting the `miran248` organization and the `private` workspace and requiring the GitHub provider; a provider block with `owner = "miran248"` and the workspace token; a sensitive `github_token` variable; a locals map with the 16 private repos and their snapshot values; the `for_each` repository resource; and one import block per repo. A README seeded by auto-init is the only other file. The private root owns exactly the 16 private repos, manages no TFC resources and no GCP resources, and reads no credential from the repository.

**Integration branches.** The spec records `integration: spec/MIR-277` and is reviewed on the `spec/MIR-277` branch forked from `main` in `org`. Because the private root lives in a second repository, `org-private` gets its own `spec/MIR-277`, forked from its seeded `main` before the stage-3 PR opens. Every child targets its own repository's `spec/MIR-277`, never `main`. The release merges both integration branches — one squash per repository — as a single release instance; that is the two-repository exception to one-ticket-one-PR, forced by the approved split. These are the Factory integration branches; they are not a per-repo long-lived branch policy and both disappear into `main` at release.

### Merged-branch cleanup

The cleanup is one-off, runs in the public delivery stage and touches only these 12 merged branches in 5 repositories. The list was re-derived at the 2026-11-21T17:17Z snapshot. At the audit snapshot `multica-sandbox/spec/mir-270` was at `b4118d3` (equal to `main`); PRs #9 and #10 later merged into it, so it is now `daf3097`, two commits ahead of `main`, and no open PR bases on it. It is not a merged-PR head and not an ancestor of the default branch, so it stays out of the delete set as a non-default integration branch. Its place in the 12 is taken by `multica-sandbox/agent/planner/mir-271-container-harness-spec` (`fd75e15`, PR #9's merged head), so the count stays 12. The other 11 rows are unchanged from the audit and were re-verified at `17:17Z`.

| Repo | Branch | Head SHA | Merged as |
| --- | --- | --- | --- |
| `miner` | `agent/implementer/c6a207a6b0fc` | `9e96af2461c676bc59ee1cd64ceb5df4229061db` | PR #10 |
| `miner` | `agent/implementer/05296821e268` | `ee03de11a579411fc0e347968de761398e972b03` | PR #24 |
| `stress-rig` | `agent/planner/mir-182-factory-lane` | `5eb945725c6fb37cbbc1d2a14b1e2d5ef15fbc21` | PR #1 |
| `abortable` | `build/publish-action` | `34cccab8ba0792013fad28b832a9ebd8003863e8` | PR #2 |
| `abortable` | `build/test-action` | `30b9539c6bcf1280ff2c276f7983547016846cc4` | PR #1 |
| `multica-sandbox` | `agent/implementer/eebfc37c0c33` | `45534bc62a1b4372df796000b3517eb339ed7b73` | PR #6 |
| `multica-sandbox` | `agent/implementer/f6398b3825cb` | `d0cc23757c7bae355209af8c42f58d8e023529df` | PR #4 |
| `multica-sandbox` | `agent/implementer/5d7b950a78a6` | `0929ee690fa8176e246373af1e2b562a00ea9e3e` | PR #5 |
| `multica-sandbox` | `agent/implementer/768a098f56c6` | `87388fd24c2f7d305ceda2b34668168ca43fb768` | PR #3 |
| `multica-sandbox` | `agent/planner/mir-179-driver-spike` | `9f35720e3e7d1daeaafba73636b94a845f07139a` | PR #1 |
| `multica-sandbox` | `agent/planner/mir-271-container-harness-spec` | `fd75e15290c7728a46522a7e7c93f0913afd739e` | PR #9 (into `spec/mir-270`) |
| `terraform-talos-modules` | `release-please--branches--main--components--terraform-talos-modules` | `7bae6a8d0429f743197a1475824951f0f7e22ff6` | PR #7 |

Order of operations:

1. **Dry run.** Re-query each branch's head SHA and merged state; compare with the table above. Abort and report if any of the 12 has a different SHA, is missing, or is the base of an open PR. Branches created or moved after the audit snapshot are out of scope: they are listed below, are never deleted, and do not abort the run. The scope never widens beyond the 12 rows.
2. **Protect open PRs.** For each of the 12, list open PRs whose base is that branch. At rework time none of the 12 is an open-PR base, so no retarget is required. If a base match appears at cleanup time, retarget or keep the branch; never delete an open-PR base and never close a PR.
3. **Delete.** Delete each branch through the GitHub API, keeping the default branch and every head branch of an open PR. Record repo, branch, full SHA and HTTP status for each of the 12 on the delivery ticket.
4. **Verify.** Every deleted ref returns 404; the open-PR heads below still resolve; the 9 forks and 3 archived repos show no change.

Never touched: the 17 open-PR heads below — the 16 audit-set PRs still open (the audit's 17 minus `multica-sandbox#9`, which merged during the slice) plus the post-audit `multica-sandbox#11` — the 9 forks and the 3 archived repos.

| Repo | PR | Head branch | Head SHA | Base |
| --- | --- | --- | --- | --- |
| `miner` | #9 | `agent/general/painterly-adoption` | `bb5a6570855890c50e724c25a7fbd97e07a17cb2` | `main` |
| `abortable` | #17 | `dependabot/npm_and_yarn/json5-2.2.3` | `c781f5fb646f8c0ba9e6a7386550c5a255ae1f9f` | `master` |
| `abortable` | #16 | `dependabot/npm_and_yarn/qs-6.5.3` | `31a638bd7521574ebf58de2eeb7459bd72bd5c21` | `master` |
| `abortable` | #15 | `dependabot/npm_and_yarn/decode-uri-component-0.2.2` | `ca346e92f4577171a5dd4bf2219b53ff837d07c7` | `master` |
| `abortable` | #14 | `dependabot/npm_and_yarn/ajv-6.12.6` | `e04d9d9d54784436bebac077a17fb64cae395042` | `master` |
| `abortable` | #13 | `dependabot/npm_and_yarn/tmpl-1.0.5` | `3cada1bce723da7961047c3aa0d4a9ec389a503f` | `master` |
| `abortable` | #12 | `dependabot/npm_and_yarn/path-parse-1.0.7` | `d83d9d29d79924693d0d216a0b8feee07b61295f` | `master` |
| `abortable` | #11 | `dependabot/npm_and_yarn/browserslist-4.16.6` | `41ec37095f2d411a5da1555f6280ea96aef4e615` | `master` |
| `abortable` | #10 | `dependabot/npm_and_yarn/hosted-git-info-2.8.9` | `ec08cae36c4ab3e10a718a34a8c3b2491fefe063` | `master` |
| `abortable` | #9 | `dependabot/npm_and_yarn/lodash-4.17.21` | `e06bf44f7a6ca74685b7a050682ac19e3ee4cb6b` | `master` |
| `abortable` | #8 | `dependabot/npm_and_yarn/handlebars-4.7.7` | `2796cf75db62f815861002b45a0d3e8f990a09ec` | `master` |
| `abortable` | #7 | `dependabot/npm_and_yarn/y18n-4.0.1` | `1c1a03b5a2ebe0f49d0dcab699905d91aa8856c3` | `master` |
| `abortable` | #6 | `dependabot/npm_and_yarn/yargs-parser-13.1.2` | `97d2677e620cefaa972e3ea8c769cc5197f3f4d4` | `master` |
| `abortable` | #3 | `dependabot/npm_and_yarn/acorn-5.7.4` | `b504241143fdc969093ad49cadcc8048d6d00f46` | `master` |
| `multica-sandbox` | #11 | `agent/planner/mir-284-release-spec` | `c31f2f395f0e756d074f49e5fc04ff9eecbec6bc` | `spec/mir-282` |
| `terra` | #44 | `release-please--branches--main` | `2a3c0568465acf77d721822b031dcc443dccaec5` | `main` |
| `factory-probe-01bf35` (archived) | #1 | `probe/head` | `8c6c52a4c584f87406447a1d534150c8defe559c` | `main` |

The archived `factory-probe-01bf35#1` head is listed so the count is accounted for; it is untouchable by policy. This slice's own PRs — the delivery `org#2` (head `MIR-279`, base `spec/MIR-277`) and the spec rework `org#3` (head `MIR-278`, base `spec/MIR-277`) — are also open when the cleanup runs; they are not in the delete set, must not be closed, and they merge into `spec/MIR-277` before the release, so they are not part of the frozen audit set.

Post-audit branches and merges are out of scope and are never in the delete set. After the 15:48Z audit, `multica-sandbox#10` merged at 17:06:52Z and its head branch `agent/implementer/585cf70e780c` was deleted on merge (404); `multica-sandbox/spec/mir-270` moved to `daf3097` and is kept; `multica-sandbox/spec/mir-282` and `spec/mir-283` were created and sit at `main`; and `multica-sandbox/agent/planner/mir-284-release-spec` is the head of open `multica-sandbox#11`. Add this slice's own `spec/MIR-277`, `MIR-278` and `MIR-279`. `spec/mir-282` and `spec/mir-283` are technically ancestors of the default branch and `spec/mir-282` is the base of `multica-sandbox#11`; all of them stay. Their presence is not a reason to abort the cleanup.

### Release verification

The release proves the slice against the live GitHub API, not against Terraform state:

- all 32 active repos are squash-only with delete-on-merge, and auto-merge, description, homepage, topics, issues, projects and wiki equal the tables above;
- the 12 refs are gone (404) and their recorded SHAs are on the delivery ticket;
- the open-PR set is preserved: the 16 audit-set PRs above (the audit's 17 minus `multica-sandbox#9`, which merged during the slice) are still open with the same head SHAs, the post-audit `multica-sandbox#11` is still open, and no deleted branch was an open-PR base; this slice's `org#2` and `org#3` have merged into `spec/MIR-277`;
- `org-private` exists, is private, is squash-only and deletes on merge;
- the `private` workspace exists in the `org` project with working directory `terraform` and a sensitive `github_token` variable;
- `terraform plan` is clean in `terraform/bootstrap` and in `org-private/terraform` against the released mains;
- the 9 forks and 3 archived repos are unmodified.

### Rollback and restore

- **Deleted branch.** Recreate the ref from its recorded SHA with `POST /repos/{owner}/{repo}/git/refs` (`ref = refs/heads/<branch>`, `sha = <recorded sha>`). If GitHub has already pruned the unreachable object, take a local mirror of the affected repo before deletion during the dry run and restore from it; the SHA table on the ticket is the source of truth either way.
- **Policy.** Reverting the Terraform change restores the snapshot: set `delete_branch_on_merge = false` and re-enable merge methods to the values in the maps (all three methods were on for 30 repos; `org` and `terraform-talos-modules` had merge-commit on and squash and rebase off, so restore merge-commit only).
- **Private root.** `org-private` is new; remove the 16 private resources and imports and delete the `private` workspace only after the private repos are back to UI management. No existing repo's Terraform ownership is destroyed by the rollback.

## Testing Decisions

Good verification here asserts externally observable state: the GitHub API and a clean Terraform plan. Nothing in the repo can be unit-tested, and asserting on Terraform state would only prove the code agrees with itself.

- **Plan seam.** After apply, `terraform plan` in both roots reports no changes and the import adoption proposes no replacement or destroy. This is the drift check, not a mock.
- **API seam.** The release reads each repo's settings, each deleted ref's HTTP status, each open PR's head SHA and the TFC workspace through the API and compares them to this spec. A mismatch is a finding, not a warning.
- **Dry-run seam.** The cleanup's dry run is the pre-destructive test: it re-derives the 12 branches from the API, refuses to delete on any difference from the recorded SHAs, and never deletes an open-PR base.
- **Prior art.** The `bootstrap` workspace is already applied from this repository and is the only precedent; there is no test harness in the repo and this slice adds none.

## Out of Scope

- The 9 forks and 3 archived repos.
- Branch protection and rulesets (unavailable on GitHub Free for private repos).
- Release-please and per-repo release automation; that is a separate epic.
- Settings outside the snapshot: Actions permissions, Pages, secrets, collaborators, webhooks, security features, merge queue.
- A new GCP project, `modules/env`, or any new Terraform Cloud organization.
- Committed audit or cleanup tooling; the cleanup is one-off and Terraform owns the flag afterwards.
- Deleting unmerged stale branches, any post-audit branch, or any branch other than the 12 above.
- Per-repo long-lived integration branches; feature branch to PR to default branch stays the model.

## Proposed breakdown

| Stage | Ticket | Delivers |
| --- | --- | --- |
| 1 | **Spec: GitHub repo governance** (MIR-278) | This spec, the repo maps, the branch lists and the approved breakdown. |
| 2 | **Public delivery: bootstrap policy, org-private and the branch cleanup** (MIR-279) | The 14 public imports, the `org` / `terraform-talos-modules` flips, the `org-private` repo, the `private` workspace with its sensitive token, and the re-derived 12-branch cleanup. |
| 3 | **Private delivery: org-private Terraform root and the 16 private imports** (MIR-280) | The `org-private/terraform` root, the GitHub provider from the workspace token and the 16 private imports. |
| 4 | **Release: verify 32 repos, 12 branch deletions and both plans** (MIR-281) | Both `spec/MIR-277` branches merged to `main`, the live API verification and the two clean plans. |

All children are published in `backlog` under MIR-277 with `Branch: spec/MIR-277`, blockers first, and the release child last. On this rework the four children already exist and were reconciled in place, never duplicated; this PR is the only approval, and no child is created after it opens.

## Further Notes

- Audit snapshot: 2026-11-21T15:48Z, run as `miran248` through the GitHub API. 44 owned repos, 32 active (16 public, 16 private), 68 branches in the active repos, 12 merged, 17 open PRs.
- Rework snapshot: 2026-11-21T17:17Z. 12 merged branches: the audit's 11 unchanged rows plus `mir-271-container-harness-spec` (PR #9's merged head); `spec/mir-270` is a non-default integration branch now at `daf3097` and stays out of scope. Open-PR heads in active repos: the 16 audit-set heads plus `multica-sandbox#11`, the archived `factory-probe-01bf35#1`, and this slice's `org#2`/`org#3`.
- `multica-sandbox#9` merged into `spec/mir-270` at 16:29Z and `multica-sandbox#10` merged into it at 17:06:52Z, deleting #10's head branch; neither is an open PR now, so no retarget is needed. `agent/planner/mir-271-container-harness-spec` (PR #9's head) is a merged-PR head and stays in the delete set.
- The repo maps are a point-in-time snapshot. Any settings change between this audit and the stage-2 apply is a rework of this spec, not an implementer decision.
- On a spec rework the same head branch `MIR-278` is force-pushed. While the spec PR is still open its link, number and body survive; because PR #1 already merged, this rework opens a new PR from that same head branch against `spec/MIR-277`.
- The epic has neither mode label: the slice is agent-implemented and agent-released, with the human merge in `awaiting_merge`.
