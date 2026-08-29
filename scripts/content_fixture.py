#!/usr/bin/env python3
"""Writes the content fixture the app's tests read, from the server that serves it.

The app's assembler test has to run against real content: one that invents its
own proves the assembler works on content nobody publishes. Nothing ships
inside the app, and since the words moved into the database no file holds them
either — so the fixture comes from the server.

    MOTTO_ADMIN_TOKEN=… scripts/content_fixture.py https://mottostage.dafalabs.com

`ContentFixtureTest` on the service side fails when the fixture falls behind,
so it cannot quietly stop being what the server would send.
"""

from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUTPUT = ROOT / "apps/motto/test/fixtures/content_bundle.json"


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__, file=sys.stderr)
        return 2

    token = os.environ.get("MOTTO_ADMIN_TOKEN")
    if not token:
        print("MOTTO_ADMIN_TOKEN is not set", file=sys.stderr)
        return 2

    request = urllib.request.Request(
        sys.argv[1].rstrip("/") + "/admin/content/bundle",
        headers={"X-Admin-Token": token},
    )
    try:
        with urllib.request.urlopen(request) as response:
            bundle = json.load(response)
    except urllib.error.HTTPError as refused:
        print(f"{refused.code} {refused.read().decode('utf-8', 'replace')}", file=sys.stderr)
        return 1

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(
        json.dumps(bundle, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    print(
        f"{OUTPUT.relative_to(ROOT)} — version {bundle['version']}, "
        f"{len(bundle['skeletons'])} days, {len(bundle['fragments'])} fragments"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
