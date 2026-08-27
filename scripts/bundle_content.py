#!/usr/bin/env python3
"""Writes the content package the app ships with, from the same files the server reads.

The app has to show something on a first launch with no network — an empty
today screen on the first day is the last day someone opens it. So the package
is baked into the assets, and replaced by the served one the moment there is a
connection.

Two copies of the text would drift, which is the thing content/ exists to
prevent. There is only one copy: this script derives the asset from the YAML,
and the version it stamps is computed exactly as ContentCatalog computes it, so
a phone that ships current does not re-download on first launch.

Run it after editing anything in content/, and commit the result.
"""

from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
CONTENT = ROOT / "content"
OUTPUT = ROOT / "apps/motto/assets/content/bundle.json"

LANGUAGE = "tr"

# Order matters: the version is a hash over these, read in this sequence. It
# has to match ContentCatalog.FILES exactly or every first launch re-downloads.
FILES = [
    "archetypes.yaml",
    "mottos.yaml",
    "daily_skeletons.yaml",
    "fragments.yaml",
    "connectors.yaml",
]


def load(name: str) -> dict:
    return yaml.safe_load((CONTENT / name).read_text(encoding="utf-8"))


def version() -> str:
    digest = hashlib.sha256()
    for name in FILES:
        digest.update((CONTENT / name).read_bytes())
    return digest.hexdigest()[:12]


def bundle() -> dict:
    return {
        "version": version(),
        "archetypes": [
            {
                "id": item["id"],
                "name": item[LANGUAGE]["name"],
                "summary": item[LANGUAGE]["summary"],
                "motto": item[LANGUAGE]["motto"],
            }
            for item in load("archetypes.yaml")["archetypes"]
        ],
        "mottos": [
            {
                "id": item["id"],
                "archetypeId": item["archetype"],
                "motto": item[LANGUAGE]["motto"],
                "detail": item[LANGUAGE]["detail"],
                "reminder": item[LANGUAGE]["reminder"],
            }
            for item in load("mottos.yaml")["mottos"]
        ],
        "skeletons": [
            {
                "day": item["day"],
                "title": item[LANGUAGE]["title"],
                "body": item[LANGUAGE]["body"],
                "action": item[LANGUAGE]["action"],
            }
            for item in load("daily_skeletons.yaml")["skeletons"]
        ],
        "fragments": [
            {
                "archetypeId": item["archetype"],
                "index": item["index"],
                "text": item[LANGUAGE],
            }
            for item in load("fragments.yaml")["fragments"]
        ],
        "connectors": [
            {"id": item["id"], "text": item[LANGUAGE]}
            for item in load("connectors.yaml")["connectors"]
        ],
    }


def main() -> int:
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    written = bundle()
    OUTPUT.write_text(
        json.dumps(written, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    print(
        f"{OUTPUT.relative_to(ROOT)} — version {written['version']}, "
        f"{len(written['skeletons'])} days, {len(written['fragments'])} fragments"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
