#!/usr/bin/env python3
from __future__ import annotations

import argparse
import shutil
import subprocess
import sys

EXPECTED_EMAIL = "fatih@fatiharge.com"
MAIN = "main"


def run(cmd: list[str], *, capture: bool = False, allow_fail: bool = False) -> str:
    print(f"$ {' '.join(cmd)}")
    result = subprocess.run(cmd, text=True, capture_output=capture)
    if result.returncode != 0:
        if allow_fail:
            return ""
        if capture and result.stderr:
            print(result.stderr, end="", file=sys.stderr)
        sys.exit(result.returncode)
    return (result.stdout or "").strip() if capture else ""


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("-b", "--branch", required=True)
    parser.add_argument("-m", "--message", required=True)
    parser.add_argument("--base", default=MAIN)
    parser.add_argument("--draft", action="store_true")
    parser.add_argument("paths", nargs="*")
    args = parser.parse_args()

    if shutil.which("gh") is None:
        sys.exit("gh (GitHub CLI) is required.")

    email = run(["git", "config", "user.email"], capture=True)
    if email != EXPECTED_EMAIL:
        sys.exit(f"refusing: git user.email is '{email}', expected '{EXPECTED_EMAIL}'.")

    current = run(["git", "branch", "--show-current"], capture=True)
    if current != MAIN:
        sys.exit(f"refusing: start from '{MAIN}' (currently on '{current}').")

    if not run(["git", "status", "--porcelain"], capture=True):
        sys.exit("nothing to commit.")

    run(["git", "switch", "-c", args.branch])
    run(["git", "add", *args.paths] if args.paths else ["git", "add", "-A"])

    if not run(["git", "diff", "--cached", "--name-only"], capture=True):
        run(["git", "switch", MAIN])
        run(["git", "branch", "-D", args.branch])
        sys.exit("nothing staged; aborted.")

    run(["git", "commit", "-m", args.message])
    run(["git", "push", "--set-upstream", "origin", args.branch])

    lines = args.message.splitlines()
    title = lines[0].strip()
    body = "\n".join(lines[1:]).strip() or title
    pr = ["gh", "pr", "create", "--base", args.base, "--head", args.branch,
          "--title", title, "--body", body]
    if args.draft:
        pr.append("--draft")
    run(pr)

    run(["git", "switch", MAIN])
    print(f"done: '{args.branch}' pushed, PR opened, back on {MAIN}.")


if __name__ == "__main__":
    main()
