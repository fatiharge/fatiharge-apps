# Architecture

> 🇹🇷 Türkçe için: [README.tr.md](README.tr.md)

Design docs for the Fatiharge Flutter monorepo. Read them in this order:

1. **[overview.md](overview.md)** — the big picture: principles, monorepo layout, dependency rules, and the standard tech stack.
2. **[package-conventions.md](package-conventions.md)** — how an individual package is structured (layers, `lib/src` + barrel, naming, testing).
3. **[git-workflow.md](git-workflow.md)** — branching, PRs, Conventional Commits, and branch protection.
4. **[testing.md](testing.md)** — what to test where, tooling, and how to run it.
5. **[dependency-injection.md](dependency-injection.md)** — wiring adapters to ports with `get_it` + `injectable`.
6. **[backend.md](backend.md)** — the services beside the workspace: modules, the OpenAPI contract, environments and CI.
7. **[app-layers.md](app-layers.md)** — inside one app: store vs repository vs cubit, what a request comes back as, and where the words live.
