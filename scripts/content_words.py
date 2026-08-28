#!/usr/bin/env python3
"""Checks user-facing copy against the App Review 1.4.1 word table.

The rule this enforces is in content/README.md: guideline 1.4.1 treats a health
claim as a health claim, and the line is drawn by which words were used rather
than by what was meant. A reviewer reads screenshots, not intentions.

Run it over content/ and over the copy that ships inside the app, because the
guideline does not care which side of the network a sentence came from.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# Stems, not whole words: Turkish suffixes would otherwise walk straight past
# every one of these ("analizi", "değerlendirmen", "teşhisi").
FORBIDDEN = {
    "değerlendirme": "envanter temelli öneri",
    "analiz": "eğilim, örüntü",
    "teşhis": "eğilim, örüntü",
    "profil çıkarımı": "eğilim, örüntü",
    "kişilik testi": "kişilik envanteri",
    "test sonuc": "envanter temelli öneri",
    "tedavi": "sana iyi gelebilecek alışkanlık",
    "terapi": "sana iyi gelebilecek alışkanlık",
}

TARGETS = [
    ROOT / "content",
    ROOT / "apps/motto/lib/features/chain/domain/turkish_reminder_copy.dart",
    ROOT / "apps/motto/lib/features/support/domain",
]

# The rulebook has to be able to name the words it forbids.
SKIP = {ROOT / "content/README.md", ROOT / "content/README.tr.md", Path(__file__)}

# Saying "this is not a diagnosis" needs the word. Denying the claim is the
# safest sentence on that screen, and dropping the word to satisfy a grep would
# weaken exactly the line that protects us. Every exception here is a denial;
# an assertion never belongs in this list.
ALLOWED = (
    "bir teşhis, bir yetenek ölçümü",
    "hiçbir cümle bir teşhis değil",
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

    if hits:
        print("copy uses words guideline 1.4.1 reads as health claims:\n")
        print("\n".join(hits))
        return 1

    print(f"1.4.1 word check passed over {len(files())} files.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
