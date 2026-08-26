#!/usr/bin/env python3
"""Branch -> commit(s) -> push -> PR.

**One shot**, from a clean start on main. Everything is already in the working
tree and gets split into commits by path; -m describes the PR:

    gitp.py -b chore/thing -m "chore: do the thing" [PATH ...]

    gitp.py -b feat/wallet -m "feat(wallet): add expense tracker" \\
      -c "fix(bootstrap_kit): complete runGuarded when the body throws" \\
         packages/bootstrap_kit/lib/src/crash packages/bootstrap_kit/test/crash \\
      -c "feat(wallet): add local-first expense tracker" apps/wallet

A -c with no paths stages whatever is left ("everything else goes here").

**Step by step**, when the work spans days and each piece is committed as it
lands rather than reconstructed from paths at the end:

    gitp.py branch feature/motto-service-skeleton
    gitp.py commit -m "feat(motto): add the Quarkus module" services/motto
    gitp.py commit -m "feat(motto): add the device registration endpoint"
    gitp.py pr -m "feat(motto): stand up the backend service" --wp 152

Run `pr` again after it is open and it just pushes the new commits onto the
same pull request.

Both shapes end in one pull request holding however many commits were made.
Commit messages go through the commit-msg hook, so Conventional Commits are
enforced per commit; the PR title is the one that lands on main, because
main only takes squash merges.
"""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys

EXPECTED_EMAIL = "fatih@fatiharge.com"
MAIN = "main"
WORK_PACKAGE_URL = "https://op.dafatek.com/work_packages"

SUBCOMMANDS = ("branch", "commit", "pr")

DRY_RUN = False


def read(cmd: list[str], *, allow_fail: bool = False) -> str:
    """Runs a read-only command and returns its stdout. Always executes."""
    result = subprocess.run(cmd, text=True, capture_output=True)
    if result.returncode != 0:
        if allow_fail:
            return ""
        if result.stderr:
            print(result.stderr, end="", file=sys.stderr)
        sys.exit(result.returncode)
    return (result.stdout or "").strip()


class CommandFailed(Exception):
    """A state-changing command exited non-zero.

    Raised rather than exiting on the spot: once a branch exists, the caller
    has to unwind it. Exiting here used to strand you on a half-built branch
    (`git add` on an ignored path was enough to trigger it).
    """

    def __init__(self, cmd: list[str], returncode: int) -> None:
        super().__init__(f"{' '.join(cmd)} exited {returncode}")
        self.returncode = returncode


def do(cmd: list[str], *, allow_fail: bool = False) -> None:
    """Runs a command that changes state. Skipped under --dry-run."""
    print(f"$ {' '.join(cmd)}")
    if DRY_RUN:
        return
    result = subprocess.run(cmd, text=True)
    if result.returncode != 0 and not allow_fail:
        raise CommandFailed(cmd, result.returncode)


def require_identity() -> None:
    email = read(["git", "config", "user.email"])
    if email != EXPECTED_EMAIL:
        sys.exit(
            f"refusing: git user.email is '{email}', expected '{EXPECTED_EMAIL}'."
        )


def require_gh() -> None:
    if shutil.which("gh") is None:
        sys.exit("gh (GitHub CLI) is required.")


def current_branch() -> str:
    return read(["git", "branch", "--show-current"])


def diagnose(paths: list[str]) -> None:
    """Prints what git saw when a group staged nothing.

    Nothing here changes the outcome — the run is aborting either way. It
    exists because "staged nothing" has several causes that look identical
    from the outside (a path that matches no change, a path whose files are
    all ignored, a path already covered by an earlier group), and by the time
    anyone reads the failure the branch is gone and the evidence with it.
    """
    scope = paths or ["."]
    print("--- diagnosis ---", file=sys.stderr)
    print(
        f"requested paths: {', '.join(paths) if paths else '(everything)'}",
        file=sys.stderr,
    )

    checks = (
        (
            "changed or untracked under those paths",
            ["git", "status", "--porcelain", "--untracked-files=all", "--", *scope],
        ),
        (
            "ignored under those paths",
            ["git", "ls-files", "--others", "--ignored", "--exclude-standard",
             "--", *scope],
        ),
        ("staged right now (repo-wide)", ["git", "diff", "--cached", "--name-only"]),
    )

    for label, cmd in checks:
        output = read(cmd, allow_fail=True)
        lines = output.splitlines()
        shown = "\n".join(f"    {line}" for line in lines[:20])
        if len(lines) > 20:
            shown += f"\n    … and {len(lines) - 20} more"
        print(f"  {label}:", file=sys.stderr)
        print(shown or "    (none)", file=sys.stderr)

    print("--- end diagnosis ---", file=sys.stderr)


def abort(branch: str, base_sha: str, reason: str) -> None:
    """Undoes the commits made so far and removes the branch.

    `reset --mixed` puts every change back in the working tree, so nothing is
    lost — you end up exactly where you started, on main.
    """
    print(f"aborting: {reason}", file=sys.stderr)
    do(["git", "reset", "--mixed", base_sha], allow_fail=True)
    do(["git", "switch", MAIN], allow_fail=True)
    do(["git", "branch", "-D", branch], allow_fail=True)
    sys.exit(1)


def open_pr(
    branch: str, message: str, base: str, draft: bool, work_package: str | None
) -> None:
    """Creates the pull request. Raises CommandFailed so callers can unwind."""
    lines = message.splitlines()
    title = lines[0].strip()
    body = "\n".join(lines[1:]).strip() or title
    # The OpenProject GitHub integration keys off this URL in the body: it posts
    # the PR onto that work package. A link added later is not picked up.
    if work_package:
        body = f"{body}\n\n{WORK_PACKAGE_URL}/{work_package}"

    cmd = [
        "gh", "pr", "create",
        "--base", base,
        "--head", branch,
        "--title", title,
        "--body", body,
    ]
    if draft:
        cmd.append("--draft")
    do(cmd)


def stage(paths: list[str]) -> bool:
    """Stages paths (or everything) and reports whether anything landed."""
    do(["git", "add", *paths] if paths else ["git", "add", "-A"])
    if DRY_RUN:
        return True
    return bool(read(["git", "diff", "--cached", "--name-only"]))


def cmd_branch(args: argparse.Namespace) -> None:
    require_identity()

    current = current_branch()
    if current != MAIN:
        sys.exit(
            f"refusing: branch off '{MAIN}' (currently on '{current}'). "
            f"Finish that branch with `gitp.py pr` first."
        )

    # Only fast-forward a clean tree. With work in progress the switch below
    # carries it onto the new branch, which is the point; pulling first would
    # risk a conflict against changes that are not committed anywhere yet.
    if not read(["git", "status", "--porcelain"]):
        do(["git", "pull", "--ff-only", "origin", MAIN], allow_fail=True)

    do(["git", "switch", "-c", args.name])
    print(
        f"\non '{args.name}'. Commit as you go:\n"
        f"  gitp.py commit -m \"type(scope): what changed\" [PATH ...]\n"
        f"then open the pull request with:\n"
        f"  gitp.py pr -m \"type(scope): what the PR delivers\""
    )


def cmd_commit(args: argparse.Namespace) -> None:
    require_identity()

    branch = current_branch()
    if branch == MAIN:
        sys.exit(
            f"refusing: nothing is committed straight to '{MAIN}'. "
            f"Start with `gitp.py branch <type>/<name>`."
        )

    if not read(["git", "status", "--porcelain"]):
        sys.exit("nothing to commit.")

    try:
        staged = stage(args.paths)
    except CommandFailed as failure:
        # `git add` on a path that matches nothing exits 128 and stages
        # nothing, so there is no half-made commit to unwind — only a message
        # to report.
        sys.exit(str(failure))

    if not staged:
        diagnose(args.paths)
        sys.exit("staged nothing — check the paths.")

    try:
        do(["git", "commit", "-m", args.message])
    except CommandFailed as failure:
        # Nothing is unwound here: the branch holds earlier commits that are
        # still wanted, and the files stay staged for a retry.
        sys.exit(
            f"{failure}\nthe files are still staged — fix the message and rerun."
        )

    print(f"\ncommitted on '{branch}'.")


def cmd_pr(args: argparse.Namespace) -> None:
    require_gh()
    require_identity()

    branch = current_branch()
    if branch == MAIN:
        sys.exit(f"refusing: '{MAIN}' has no pull request to open.")

    do(["git", "fetch", "origin", args.base], allow_fail=True)
    ahead = read(
        ["git", "rev-list", "--count", f"origin/{args.base}..HEAD"], allow_fail=True
    )
    if ahead == "0":
        sys.exit(
            f"no commits on '{branch}' yet — `gitp.py commit` at least once first."
        )

    # Re-running this after the pull request is open is how commits are added
    # to it, so settle whether there is anything to create before pushing.
    existing = read(
        ["gh", "pr", "view", branch, "--json", "url", "--jq", ".url"],
        allow_fail=True,
    )
    if not existing and not args.message:
        sys.exit("-m is required to open a pull request.")

    upstream = read(
        ["git", "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}"],
        allow_fail=True,
    )
    push = ["git", "push"] if upstream else [
        "git", "push", "--set-upstream", "origin", branch
    ]

    try:
        do(push)
    except CommandFailed as failure:
        sys.exit(str(failure))

    if not existing:
        try:
            open_pr(branch, args.message, args.base, args.draft, args.work_package)
        except CommandFailed as failure:
            print(f"\n{failure}", file=sys.stderr)
            sys.exit(
                f"the branch is pushed but no PR was opened. Retry with:\n"
                f"  gh pr create --base {args.base} --head {branch}"
            )

    leftover = read(["git", "status", "--porcelain"])
    if leftover and not DRY_RUN:
        print("\nnote: still uncommitted on this branch:")
        print(leftover)

    if existing:
        print(f"\ndone: '{branch}' pushed to its open pull request: {existing}")
        return

    counted = (
        f"{ahead} commit{'s' if ahead != '1' else ''}" if ahead.isdigit()
        else "its commits"
    )
    print(
        f"\ndone: '{branch}' pushed with {counted} and a PR open. "
        f"Still on the branch — `git switch {MAIN}` once it is merged."
    )


def run_one_shot(args: argparse.Namespace) -> None:
    require_gh()
    require_identity()

    current = current_branch()
    if current != MAIN:
        sys.exit(f"refusing: start from '{MAIN}' (currently on '{current}').")

    if not read(["git", "status", "--porcelain"]):
        sys.exit("nothing to commit.")

    if args.commits and args.paths:
        sys.exit("use either -c groups or trailing paths, not both.")

    # One shape for both modes: a list of [message, *paths].
    specs: list[list[str]] = args.commits or [[args.message, *args.paths]]

    base_sha = read(["git", "rev-parse", "HEAD"])
    do(["git", "switch", "-c", args.branch])

    # Everything from here until the push is undoable, so any failure unwinds
    # the branch instead of leaving you standing on half of it.
    try:
        for index, spec in enumerate(specs, start=1):
            message, paths = spec[0], spec[1:]
            if not stage(paths):
                diagnose(paths)
                abort(
                    args.branch,
                    base_sha,
                    f"commit {index} ({message.splitlines()[0]!r}) staged "
                    "nothing — check its paths.",
                )

            do(["git", "commit", "-m", message])
    except CommandFailed as failure:
        abort(args.branch, base_sha, str(failure))

    # Still undoable: a failed push leaves nothing behind on the remote.
    try:
        do(["git", "push", "--set-upstream", "origin", args.branch])
    except CommandFailed as failure:
        abort(args.branch, base_sha, str(failure))

    # Past the push, rolling back would delete a local branch that already
    # exists on the remote. The commits are safe; only the PR is missing.
    try:
        open_pr(
            args.branch, args.message, args.base, args.draft, args.work_package
        )
    except CommandFailed as failure:
        print(f"\n{failure}", file=sys.stderr)
        sys.exit(
            f"the branch is pushed but no PR was opened. Retry with:\n"
            f"  gh pr create --base {args.base} --head {args.branch}"
        )

    # Read before switching. On main the branch's own .gitignore files are
    # gone from disk, so build and IDE artefacts they cover suddenly look
    # untracked — which reported a forgotten path that was never forgotten.
    leftover = read(["git", "status", "--porcelain"])

    do(["git", "switch", MAIN])

    # Anything not covered by the -c groups is still sitting in the working
    # tree and came back to main with you. Usually a forgotten path.
    if leftover and not DRY_RUN:
        print("\nnote: left uncommitted in the working tree:")
        print(leftover)

    count = len(specs)
    print(
        f"\ndone: '{args.branch}' pushed with {count} "
        f"commit{'s' if count != 1 else ''}, PR opened, back on {MAIN}."
    )


def add_dry_run(parser: argparse.ArgumentParser) -> None:
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print what would run without touching the repo or GitHub.",
    )


def parse_stepwise(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="gitp.py",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description=__doc__,
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    branch = subparsers.add_parser("branch", help="Open a branch off main.")
    branch.add_argument("name", help="<type>/<short-kebab-description>")
    add_dry_run(branch)
    branch.set_defaults(func=cmd_branch)

    commit = subparsers.add_parser(
        "commit", help="Commit part of the work on the current branch."
    )
    commit.add_argument("-m", "--message", required=True)
    commit.add_argument(
        "paths",
        nargs="*",
        help="What belongs in this commit. Omit to take everything pending.",
    )
    add_dry_run(commit)
    commit.set_defaults(func=cmd_commit)

    pr = subparsers.add_parser(
        "pr", help="Push the current branch and open its pull request."
    )
    pr.add_argument(
        "-m",
        "--message",
        help="PR title (+ body). Required only when the PR does not exist yet.",
    )
    pr.add_argument("--base", default=MAIN)
    pr.add_argument("--draft", action="store_true")
    pr.add_argument(
        "--wp",
        dest="work_package",
        help="OpenProject work package id to link in the PR body.",
    )
    add_dry_run(pr)
    pr.set_defaults(func=cmd_pr)

    return parser.parse_args(argv)


def parse_one_shot() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description=__doc__,
    )
    parser.add_argument("-b", "--branch", required=True)
    parser.add_argument(
        "-m",
        "--message",
        required=True,
        help="PR title (+ body after the first line). Also the commit "
        "message when no -c is given.",
    )
    parser.add_argument(
        "-c",
        "--commit",
        action="append",
        nargs="+",
        dest="commits",
        metavar=("MESSAGE", "PATH"),
        help="One commit: a message followed by its paths. Repeatable. "
        "Omit the paths to sweep up everything still uncommitted.",
    )
    parser.add_argument("--base", default=MAIN)
    parser.add_argument("--draft", action="store_true")
    parser.add_argument(
        "--wp",
        dest="work_package",
        help="OpenProject work package id to link in the PR body.",
    )
    add_dry_run(parser)
    parser.add_argument("paths", nargs="*")
    return parser.parse_args()


def main() -> None:
    global DRY_RUN

    if len(sys.argv) > 1 and sys.argv[1] in SUBCOMMANDS:
        args = parse_stepwise(sys.argv[1:])
        DRY_RUN = args.dry_run
        args.func(args)
        return

    args = parse_one_shot()
    DRY_RUN = args.dry_run
    run_one_shot(args)


if __name__ == "__main__":
    main()
