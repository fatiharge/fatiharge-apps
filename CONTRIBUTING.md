# Contributing

> 🇹🇷 Türkçe için: [CONTRIBUTING.tr.md](CONTRIBUTING.tr.md)

Thanks for contributing! This repository **requires [Conventional Commits](https://www.conventionalcommits.org/)**. This is not just a style choice — it drives automated package versioning and changelog generation in this Flutter monorepo.

## Commit message format

```
<type>(<scope>)?<!>?: <description>
```

- **type** — one of the allowed types below (required)
- **scope** — the affected package/area, e.g. `auth`, `core_ui` (optional)
- **!** — marks a breaking change (optional)
- **description** — short summary in the imperative mood (required)

### Allowed types

| Type       | When to use                                             |
| ---------- | ------------------------------------------------------- |
| `feat`     | A new feature                                           |
| `fix`      | A bug fix                                               |
| `docs`     | Documentation only                                      |
| `style`    | Formatting, no code-behavior change                     |
| `refactor` | Code change that is neither a feature nor a fix         |
| `perf`     | Performance improvement                                 |
| `test`     | Adding or fixing tests                                  |
| `build`    | Build system or dependencies                            |
| `ci`       | CI configuration                                        |
| `chore`    | Maintenance tasks                                       |
| `revert`   | Reverting a previous commit                             |

### Examples

```
feat: add user login
fix(auth): fix token refresh bug
feat(payments)!: change API contract
chore(deps): bump dependencies
docs: update setup instructions
```

## How it is enforced

There are two layers:

1. **Local git hook (early warning).** A `commit-msg` hook rejects a non-conforming message the moment you commit. Enable it once after cloning:

   ```bash
   ./.githooks/setup.sh
   # or:
   git config core.hooksPath .githooks
   ```

   > Local hooks are not installed automatically on clone, and can be bypassed with `git commit --no-verify`. They are a convenience, not the real gate.

2. **CI (the real gate).** A GitHub Actions workflow validates the **pull request title** against the same rules. A non-conforming title fails the check and blocks merge. Because we squash-merge, the merge commit is built from the PR title.

## Tips

- If your commit fails the hook, fix the message with `git commit --amend`.
- Keep the description in the imperative mood: "add", "fix", "update" — not "added"/"fixes".
- Use a scope that matches the package you touched in the monorepo.
