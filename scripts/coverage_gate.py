#!/usr/bin/env python3
"""Fails the build when a package's line coverage drops below its floor.

Run after `flutter test --coverage` has been executed in every package that
has tests — `melos run coverage:check` does both.

The floors sit a few points under what each package measures today. They are a
ratchet against a real slide, not a target: a number tight enough to trip on a
one-line refactor teaches people to add `// coverage:ignore` instead of tests.
Raise a floor when a package settles comfortably above it.
"""

from __future__ import annotations

import sys
from pathlib import Path

FLOORS = {
    # A skeleton: the theme and the one page are covered, the wiring around
    # them is not yet worth a test. This rises as screens land — it is a
    # ratchet, and leaving it at the default would only teach us to skip the
    # helper that makes the number honest.
    "motto": 58.0,
    "wallet": 85.0,
    "bootstrap_kit": 95.0,
    "utility_kit": 95.0,
}

DEFAULT_FLOOR = 80.0

ROOT = Path(__file__).resolve().parent.parent


def packages_with_tests() -> list[Path]:
    """Every package melos would have run tests in."""
    return sorted(
        path
        for parent in ("apps", "packages")
        for path in (ROOT / parent).iterdir()
        if (path / "test").is_dir()
    )


def line_coverage(lcov: Path) -> tuple[int, int]:
    hit = total = 0
    for line in lcov.read_text().splitlines():
        if line.startswith("DA:"):
            total += 1
            if int(line[3:].split(",")[1]) > 0:
                hit += 1
    return hit, total


def main() -> int:
    failures: list[str] = []

    print(f"{'package':<18}{'covered':>14}{'coverage':>11}{'floor':>9}")
    print("-" * 52)

    for package in packages_with_tests():
        lcov = package / "coverage" / "lcov.info"
        floor = FLOORS.get(package.name, DEFAULT_FLOOR)

        if not lcov.is_file():
            # Silence here would read as a pass, which is the one outcome a
            # missing report must not produce.
            print(f"{package.name:<18}{'no lcov.info':>14}")
            failures.append(f"{package.name}: no coverage report at {lcov}")
            continue

        hit, total = line_coverage(lcov)
        if total == 0:
            print(f"{package.name:<18}{'no lines':>14}")
            failures.append(f"{package.name}: report covers no lines")
            continue

        percent = hit / total * 100
        mark = "" if percent >= floor else "  <-- below floor"
        print(
            f"{package.name:<18}{f'{hit}/{total}':>14}"
            f"{percent:>10.2f}%{floor:>8.0f}%{mark}"
        )
        if percent < floor:
            failures.append(
                f"{package.name}: {percent:.2f}% is under its {floor:.0f}% floor"
            )

    if failures:
        print("\ncoverage gate failed:", file=sys.stderr)
        for failure in failures:
            print(f"  - {failure}", file=sys.stderr)
        return 1

    print("\ncoverage gate passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
