# Git Workflow

> 🇹🇷 Türkçe için: [git-workflow.tr.md](git-workflow.tr.md)

This document describes how we branch, commit, and merge in this Flutter monorepo.

- Commit rules and allowed types: [CONTRIBUTING.md](../CONTRIBUTING.md)
- Türkçe katkı rehberi: [CONTRIBUTING.tr.md](../CONTRIBUTING.tr.md)

## Branch strategy

We use a **trunk-based** flow with a single long-lived branch.

| Branch          | Role                                                            |
| --------------- | -------------------------------------------------------------- |
| `main`          | The single source of truth. Always releasable, always green.   |
| `feature/*`     | New functionality.                                             |
| `fix/*`         | Bug fixes.                                                     |
| `chore/*`       | Maintenance: deps, tooling, CI, config, docs.                  |

- Every change lands on `main` through a **pull request** — no direct pushes.
- Short-lived branches: open a PR early, keep it small, merge fast the branch.
- Branch off the latest `main`; if `main` moves ahead, bring your branch up to
  date with GitHub's **Update branch** button.

### Naming

```
<type>/<short-kebab-description>
```

The `type` prefix mirrors the Conventional Commit types so intent is obvious at a glance.

```
feature/user-login
feature/payments-apple-pay
fix/auth-token-refresh
chore/bump-flutter-3-24
```

Optionally include a package/scope: `feature/auth/social-login`.

## Commit messages — Conventional Commits

Every commit **must** follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>)?<!>?: <description>
```

- Enforced **locally** by the `.githooks/commit-msg` hook (run `./.githooks/setup.sh` once after cloning).
- Enforced in **CI** on the PR title (see below).
- The scope should match the monorepo package you touched (`auth`, `core_ui`, …).
- `!` (or a `BREAKING CHANGE:` footer) marks a breaking change.

Full rules, type table, and examples live in [CONTRIBUTING.md](../CONTRIBUTING.md). This convention also drives automated package versioning and changelogs (Melos) as the monorepo grows.

## Pull request process

1. **Branch** off the latest `main` using the naming above.
2. **Commit** with Conventional Commit messages.
3. **Open a PR** into `main`. The PR **title must be a valid Conventional Commit** — we squash-merge, so the merge commit is built from the title.
4. **CI must pass.** The `Conventional PR Title` workflow validates the title; other checks (tests, analyze) are added as the project grows.
5. **Review** — at least one approval required.
6. **Squash and merge** — the only method the ruleset allows. See [Scope a PR, and title it for every package it touches](#scope-a-pr-and-title-it-for-every-package-it-touches).
7. **Delete** the branch after merge.

### Scope a PR, and title it for every package it touches

**Prefer one PR per workspace member.** Split whenever the changes are
independent — it keeps each one reviewable and revertable on its own.

When they are genuinely *coupled*, ship them together. A package changing its
API and the app following it belong in one PR; splitting that into an
expand/deprecate/contract sequence buys correctness we can get more cheaply
from the title.

The reason the title matters: `melos version` attributes a commit to a package
by the files it touched, but takes the changelog text from the commit
*subject*. We squash-merge, so a PR spanning two members leaves **one** subject
and **every** member touched gets that exact line.

So for a PR that touches more than one member, **leave the scope out**:

```
refactor!: take the splash from the page, not the port     ← good
refactor(bootstrap_kit)!: take the splash from …           ← wallet's changelog
                                                              now names another
                                                              package
```

The scope is optional in Conventional Commits and the PR title check accepts
it either way. Dropping it costs nothing and stops a package's changelog from
claiming work that belongs to its neighbour. `wallet` reaching `0.2.0` off a
`refactor(bootstrap_kit)!` title is what this avoids.

Merging is always **squash**: the ruleset on `main` allows no other method and
requires linear history. Nothing broken can reach `main` regardless — both CI
checks are required to pass first.

`architecture/`, `.github/`, `scripts/` and root config belong to no member, so
they never affect any of this and can ride along with any PR.

### Why squash-merge

- `main` stays linear: one commit per PR, each a clean Conventional Commit.
- We only need to enforce the **PR title** (the future squash commit), not every intermediate WIP commit.
- Clean input for automated changelog/versioning.

## Branch protection (GitHub settings)

Configured as a **ruleset** (`main-protection`) rather than classic branch
protection — GitHub → **Settings → Rules → Rulesets**. Note that the older
`/branches/main/protection` API returns 404 for rulesets, which makes it easy to
conclude the branch is unprotected when it is not.

What is enforced on `main` today:

- **Require a pull request before merging**, squash as the only allowed method.
  No approval is required — a single maintainer approving their own work adds
  nothing.
- **Require status checks:** `Analyze, format & test` and `Validate PR title`.
- **Require linear history**, block deletion, block force-pushes.
- **Not** enabled: *require branches to be up to date before merging*. A PR is
  therefore tested against the `main` it was opened from, not necessarily the
  one it lands on — which is why CI also runs on every push to `main`.

Repository → **Settings → General → Pull Requests**:

- Allow **squash merging** only — the other two methods are off.
- **Automatically delete head branches** after merge.

> Until these settings are enabled in the GitHub UI, the CI check reports status but cannot *block* a merge. Branch protection is what turns the convention into a hard gate.
