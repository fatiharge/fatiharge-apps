#!/usr/bin/env bash
# Run once after cloning the repo:  ./.githooks/setup.sh
# Tells Git to use the versioned .githooks/ directory.
set -e
git config core.hooksPath .githooks
echo "Git hooks installed (core.hooksPath = .githooks)."
