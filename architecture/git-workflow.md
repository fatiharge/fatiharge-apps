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
- Branch off the latest `main`; rebase on `main` if it moves ahead of you.

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
6. **Squash and merge.** Keep `main` history linear and readable.
7. **Delete** the branch after merge.

### Why squash-merge

- `main` stays linear: one commit per PR, each a clean Conventional Commit.
- We only need to enforce the **PR title** (the future squash commit), not every intermediate WIP commit.
- Clean input for automated changelog/versioning.

## Branch protection (GitHub settings)

Configure on GitHub → **Settings → Branches → Add rule** for `main`:

- ✅ **Require a pull request before merging** (no direct pushes to `main`).
  - Require at least **1 approval**.
-  **Require status checks to pass before merging.**
  - Select **`Validate PR title`** (from the `Conventional PR Title` workflow).
  -  Require branches to be up to date before merging.
-  **Require linear history** (pairs with squash-merge).
-  Optionally: require conversation resolution, block force-pushes, include administrators.

Repository → **Settings → General → Pull Requests**:

- Allow **squash merging** only (disable merge commits and rebase merging).
- **Automatically delete head branches** after merge.

> Until these settings are enabled in the GitHub UI, the CI check reports status but cannot *block* a merge. Branch protection is what turns the convention into a hard gate.
