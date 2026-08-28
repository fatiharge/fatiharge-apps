#!/usr/bin/env python3
"""Pushes everything in content/ that lives in the database into the database.

Tasks and report pieces are data, not schema. They used to be two generated
repeatable migrations — hundreds of committed INSERT lines — which made
correcting one sentence a release and put the words in the schema history
instead of the tables. They go over /admin/content now.

    MOTTO_ADMIN_TOKEN=… scripts/push_content.py https://mottostage.dafalabs.com

Idempotent: every row is addressed by the slot it fills, so running it twice
changes nothing and pushing one corrected line leaves the rest alone.

Anything nobody has written yet is sent as a marked stand-in, so the writing
job is a request — GET /admin/content/unwritten — rather than a memory.
"""

from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.request
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
CONTENT = ROOT / "content"

DIMENSIONS = [
    "OPENNESS",
    "CONSCIENTIOUSNESS",
    "EXTRAVERSION",
    "AGREEABLENESS",
    "NEUROTICISM",
]
BANDS = ["low", "mid", "high"]
SECTIONS = [1, 2, 3, 4]
LANGUAGE = "tr"


def load(name: str):
    return yaml.safe_load((CONTENT / name).read_text(encoding="utf-8"))


def text_of(entry) -> str | None:
    """A written entry is a mapping with the language in it, or nothing yet."""
    if isinstance(entry, dict):
        return entry.get(LANGUAGE)
    return entry if isinstance(entry, str) else None


def tasks_for(archetypes: list[str]) -> list[dict]:
    content = load("tasks.yaml")
    days = content["tasks"]
    # Which of the three the archetype is supposed to own. The other two are
    # the day's move and the day's mark — the same for everyone by design, so
    # they are not stand-ins waiting to be replaced.
    personal = content["personal_slot"]
    rows = []
    for day in days:
        shared = day[LANGUAGE]
        written = day.get("by_archetype", {})
        for archetype in archetypes:
            overrides = written.get(archetype, {})
            for ordinal, fallback in enumerate(shared, start=1):
                one = overrides.get(ordinal)
                rows.append(
                    {
                        "day": day["day"],
                        "archetypeId": archetype,
                        "ordinal": ordinal,
                        "title": (one or fallback)["title"],
                        "detail": (one or fallback)["detail"],
                        "placeholder": ordinal == personal and one is None,
                    }
                )
    return rows


def piece(kind, text, *, archetype=None, dimension=None, band=None, section=None):
    written = text is not None
    return {
        "kind": kind,
        "archetypeId": archetype,
        "dimension": dimension,
        "band": band,
        "section": section,
        "text": text if written else stand_in(kind, archetype, dimension, band, section),
        "placeholder": not written,
    }


def stand_in(kind, archetype, dimension, band, section) -> str:
    slot = " · ".join(
        str(part) for part in (archetype, dimension, band, section) if part is not None
    )
    return f"[{kind} · {slot}] Bu metin henüz yazılmadı."


def report_for(archetypes: list[str]) -> list[dict]:
    report = load("report.yaml")
    readings = report.get("readings", {})
    dimensions = report.get("dimensions", {})
    fragments = report.get("fragments", {})

    pieces = [piece("limitation", text_of(report["limitation"]))]
    pieces += [
        piece("skeleton", text_of(entry), section=entry["section"])
        for entry in report["sections"]
    ]

    for dimension in DIMENSIONS:
        for band in BANDS:
            for kind, source in (("reading", readings), ("dimension", dimensions)):
                pieces.append(
                    piece(
                        kind,
                        text_of(source.get(dimension, {}).get(band)),
                        dimension=dimension,
                        band=band,
                    )
                )

    for archetype in archetypes:
        for kind in ("overview", "strength", "cost", "portrait", "comparison"):
            pieces.append(
                piece(
                    kind,
                    text_of(report.get(f"{kind}s", {}).get(archetype)),
                    archetype=archetype,
                )
            )
        for section in SECTIONS:
            pieces.append(
                piece(
                    "fragment",
                    text_of(fragments.get(archetype, {}).get(section)),
                    archetype=archetype,
                    section=section,
                )
            )
    return pieces


def put(host: str, token: str, path: str, body: list[dict]) -> dict:
    request = urllib.request.Request(
        f"{host.rstrip('/')}/admin/content/{path}",
        data=json.dumps(body).encode("utf-8"),
        method="PUT",
        headers={"Content-Type": "application/json", "X-Admin-Token": token},
    )
    with urllib.request.urlopen(request, timeout=60) as response:
        return json.loads(response.read())


def main(argv: list[str]) -> int:
    if len(argv) != 2:
        print(f"usage: {argv[0]} <host>", file=sys.stderr)
        return 2

    token = os.environ.get("MOTTO_ADMIN_TOKEN", "")
    if not token:
        print("MOTTO_ADMIN_TOKEN is not set.", file=sys.stderr)
        return 2

    host = argv[1]
    archetypes = [item["id"] for item in load("archetypes.yaml")["archetypes"]]

    try:
        for path, rows in (
            ("tasks", tasks_for(archetypes)),
            ("report-pieces", report_for(archetypes)),
        ):
            summary = put(host, token, path, rows)
            print(
                f"{path}: {summary['written']} pushed, "
                f"{summary['placeholders']} still unwritten"
            )
    except urllib.error.HTTPError as failure:
        # 404 is what a wrong or missing token looks like from out here: the
        # endpoint does not admit to existing.
        print(f"{failure.code} {failure.reason}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
