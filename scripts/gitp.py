#!/usr/bin/env python3
"""Branch -> commit(s) -> push -> PR, from a clean start on main.

Single commit (unchanged behaviour):

    gitp.py -b chore/thing -m "chore: do the thing" [PATH ...]

Several commits in ONE pull request: repeat -c, each with its own message and
the paths that belong to it. -m then describes the PR, not a commit.

    gitp.py -b feat/wallet -m "feat(wallet): add expense tracker" \\
      -c "fix(bootstrap_kit): complete runGuarded when the body throws" \\
         packages/bootstrap_kit/lib/src/crash packages/bootstrap_kit/test/crash \\
      -c "feat(wallet): add local-first expense tracker" apps/wallet

A -c with no paths stages whatever is left ("everything else goes here").
Commit messages go through the commit-msg hook, so Conventional Commits are
enforced per commit as usual.
"""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys

EXPECTED_EMAIL = "fatih@fatiharge.com"
MAIN = "main"

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


def do(cmd: list[str], *, allow_fail: bool = False) -> None:
    """Runs a command that changes state. Skipped under --dry-run."""
    print(f"$ {' '.join(cmd)}")
    if DRY_RUN:
        return
    result = subprocess.run(cmd, text=True)
    if result.returncode != 0 and not allow_fail:
        sys.exit(result.returncode)


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


def main() -> None:
    global DRY_RUN

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
        "--dry-run",
        action="store_true",
        help="Print what would run without touching the repo or GitHub.",
    )
    parser.add_argument("paths", nargs="*")
    args = parser.parse_args()

    DRY_RUN = args.dry_run

    if shutil.which("gh") is None:
        sys.exit("gh (GitHub CLI) is required.")

    email = read(["git", "config", "user.email"])
    if email != EXPECTED_EMAIL:
        sys.exit(
            f"refusing: git user.email is '{email}', expected '{EXPECTED_EMAIL}'."
        )

    current = read(["git", "branch", "--show-current"])
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

    for index, spec in enumerate(specs, start=1):
        message, paths = spec[0], spec[1:]
        do(["git", "add", *paths] if paths else ["git", "add", "-A"])

        if not DRY_RUN and not read(["git", "diff", "--cached", "--name-only"]):
            abort(
                args.branch,
                base_sha,
                f"commit {index} ({message.splitlines()[0]!r}) staged nothing "
                "— check its paths.",
            )

        do(["git", "commit", "-m", message])

    do(["git", "push", "--set-upstream", "origin", args.branch])

    lines = args.message.splitlines()
    title = lines[0].strip()
    body = "\n".join(lines[1:]).strip() or title
    pr = [
        "gh", "pr", "create",
        "--base", args.base,
        "--head", args.branch,
        "--title", title,
        "--body", body,
    ]
    if args.draft:
        pr.append("--draft")
    do(pr)

    do(["git", "switch", MAIN])

    # Anything not covered by the -c groups is still sitting in the working
    # tree and came back to main with you. Usually a forgotten path.
    leftover = read(["git", "status", "--porcelain"])
    if leftover and not DRY_RUN:
        print("\nnote: left uncommitted in the working tree:")
        print(leftover)

    count = len(specs)
    print(
        f"\ndone: '{args.branch}' pushed with {count} "
        f"commit{'s' if count != 1 else ''}, PR opened, back on {MAIN}."
    )


if __name__ == "__main__":
    main()
