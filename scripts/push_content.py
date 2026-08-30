#!/usr/bin/env python3
"""Pushes a language's words into the tables that hold them.

The words are data, not code: they go in through `PUT /admin/content/…` so a
correction costs one request rather than a deploy. This is the same door, with
the payload read from a directory instead of typed by hand.

Every write names its language. The tables that are *not* worded — where an
archetype sits in five dimensions, which generation of the inventory is live —
are written from the fallback language and from nowhere else, so pushing a
translation cannot change who gets which archetype.

    MOTTO_ADMIN_TOKEN=… scripts/push_content.py https://mottostage.dafalabs.com en
    MOTTO_ADMIN_TOKEN=… scripts/push_content.py https://mottostage.dafalabs.com en --dry-run

The payload lives in `content/<locale>/`, one file per endpoint. A file that is
not there is a part that is not pushed, which is how a translation lands in
pieces rather than all at once.
"""

from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# In order: the report sections and the archetypes have to exist before the
# rows that address them by id do.
PARTS = [
    ("archetypes", "/admin/content/archetypes"),
    ("items", "/admin/content/items"),
    ("mottos", "/admin/content/mottos"),
    ("skeletons", "/admin/content/skeletons"),
    ("fragments", "/admin/content/fragments"),
    ("connectors", "/admin/content/connectors"),
    ("support", "/admin/content/support"),
    ("tasks", "/admin/content/tasks"),
    ("report_pieces", "/admin/content/report-pieces"),
]

# The items endpoint takes a set rather than a list: one generation of the
# inventory, with the questions inside it.
ITEM_SET_VERSION = 1


def main() -> int:
    if len(sys.argv) < 3:
        sys.exit(__doc__)

    base, locale = sys.argv[1].rstrip("/"), sys.argv[2]
    dry = "--dry-run" in sys.argv[3:]

    token = os.environ.get("MOTTO_ADMIN_TOKEN")
    if not token and not dry:
        sys.exit("MOTTO_ADMIN_TOKEN is not set")

    payloads = ROOT / "content" / locale
    if not payloads.is_dir():
        sys.exit(f"no payload directory at {payloads.relative_to(ROOT)}")

    for name, path in PARTS:
        file = payloads / f"{name}.json"
        if not file.is_file():
            print(f"  {name}: not written yet, skipped")
            continue

        body = json.loads(file.read_text(encoding="utf-8"))
        if name == "items":
            # Never activating: which generation is live is not a translator's
            # decision, and the server ignores the flag off the fallback anyway.
            body = {"version": ITEM_SET_VERSION, "activate": False, "items": body}

        rows = len(body) if isinstance(body, list) else len(body["items"])
        if dry:
            print(f"  {name}: {rows} rows would go to {path}?locale={locale}")
            continue

        answer = put(f"{base}{path}?locale={locale}", body, token)
        print(f"  {name}: {rows} rows written, {answer}")

    if not dry:
        print("\nwhat is still a stand-in:")
        print("  " + json.dumps(get(f"{base}/admin/content/unwritten?locale={locale}", token)))
        objections = get(f"{base}/admin/content/objections?locale={locale}", token)
        if objections:
            print("\n1.4.1 objections:")
            print("\n".join(f"  {each}" for each in objections))
            return 1
    return 0


def put(url: str, body: object, token: str) -> object:
    request = urllib.request.Request(
        url,
        data=json.dumps(body, ensure_ascii=False).encode("utf-8"),
        headers={"Content-Type": "application/json", "X-Admin-Token": token},
        method="PUT",
    )
    return send(request)


def get(url: str, token: str) -> object:
    return send(urllib.request.Request(url, headers={"X-Admin-Token": token}))


def send(request: urllib.request.Request) -> object:
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            raw = response.read()
            return json.loads(raw) if raw else None
    except urllib.error.HTTPError as refused:
        # The server refuses a whole push rather than half of it, and it says
        # which sentence it refused over. Printing that is the point.
        sys.exit(f"{refused.code} {refused.read().decode('utf-8', 'replace')}")


if __name__ == "__main__":
    raise SystemExit(main())
