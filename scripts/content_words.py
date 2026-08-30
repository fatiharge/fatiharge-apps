#!/usr/bin/env python3
"""Checks user-facing copy against the App Review 1.4.1 word table.

The rule this enforces is in content/README.md: guideline 1.4.1 treats a health
claim as a health claim, and the line is drawn by which words were used rather
than by what was meant. A reviewer reads screenshots, not intentions.

The words the server sends are checked by the server: they come in through
/admin/content, which refuses them, and GET /admin/content/objections re-reads
every row for the ones that were written straight into the database. Give this
script a base URL and it asks. Without one it checks only the copy that ships
inside the app — which still needs checking, because the guideline does not
care which side of the network a sentence came from.

    scripts/content_words.py
    MOTTO_ADMIN_TOKEN=… scripts/content_words.py https://mottostage.dafalabs.com
"""

from __future__ import annotations

import json
import os
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# One table per language, and both are checked over the same files: the
# translation files hold two languages side by side, and a Turkish stem list
# has nothing to say about the word "diagnosis". Stems rather than whole words —
# Turkish suffixes ("analizi", "teşhisi") and English endings ("diagnosing")
# would otherwise both walk straight past.
FORBIDDEN = {
    "değerlendirme": "envanter temelli öneri",
    "analiz": "eğilim, örüntü",
    "teşhis": "eğilim, örüntü",
    "profil çıkarımı": "eğilim, örüntü",
    "kişilik testi": "kişilik envanteri",
    "test sonuc": "envanter temelli öneri",
    "tedavi": "sana iyi gelebilecek alışkanlık",
    "terapi": "sana iyi gelebilecek alışkanlık",
    "diagnos": "tendency, pattern",
    "personality test": "personality inventory",
    "test result": "inventory-based suggestion",
    "treatment": "a habit that may suit you",
    "therapy": "a habit that may suit you",
}

TARGETS = [
    ROOT / "apps/motto/assets/translations",
    ROOT / "apps/motto/lib/features/chain/domain/reminder_words.dart",
    ROOT / "apps/motto/lib/features/support/domain",
]

# The rulebook has to be able to name the words it forbids.
SKIP = {Path(__file__)}

# Saying "this is not a diagnosis" needs the word. Denying the claim is the
# safest sentence on that screen, and dropping the word to satisfy a grep would
# weaken exactly the line that protects us. Every exception here is a denial;
# an assertion never belongs in this list.
ALLOWED = (
    "bir teşhis, bir yetenek ölçümü",
    "hiçbir cümle bir teşhis değil",
    "not a diagnosis",
    "no sentence here is a diagnosis",
)


def files() -> list[Path]:
    found: list[Path] = []
    for target in TARGETS:
        if target.is_dir():
            found.extend(p for p in target.rglob("*") if p.is_file())
        elif target.is_file():
            found.append(target)
    return [p for p in found if p not in SKIP]


def main() -> int:
    hits: list[str] = []

    for path in files():
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue

        for number, line in enumerate(text.splitlines(), start=1):
            lowered = line.lower()
            if any(phrase in lowered for phrase in ALLOWED):
                continue
            for word, instead in FORBIDDEN.items():
                if re.search(re.escape(word), lowered):
                    hits.append(
                        f"  {path.relative_to(ROOT)}:{number}: "
                        f"'{word}' — use: {instead}"
                    )

    if len(sys.argv) > 1:
        # Every language the server holds, not only the one it falls back to:
        # a sentence written in English is read by a reviewer in English.
        for locale in ("tr", "en"):
            hits.extend(
                f"  [{locale}] {objection}"
                for objection in served(sys.argv[1], locale)
            )

    if hits:
        print("copy uses words guideline 1.4.1 reads as health claims:\n")
        print("\n".join(hits))
        return 1

    print(f"1.4.1 word check passed over {len(files())} files.")
    return 0


def served(base: str, locale: str) -> list[str]:
    """What the server says about the words it holds, in one language."""
    token = os.environ.get("MOTTO_ADMIN_TOKEN")
    if not token:
        sys.exit("MOTTO_ADMIN_TOKEN is not set")

    request = urllib.request.Request(
        base.rstrip("/") + f"/admin/content/objections?locale={locale}",
        headers={"X-Admin-Token": token},
    )
    try:
        with urllib.request.urlopen(request) as response:
            return json.load(response)
    except urllib.error.HTTPError as refused:
        sys.exit(f"{refused.code} {refused.read().decode('utf-8', 'replace')}")


if __name__ == "__main__":
    sys.exit(main())
