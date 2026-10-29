#!/usr/bin/env bash
# One-time setup per clone: teach git how to run the nbstrip filter that .gitattributes asks for.
# Without this, committed notebooks carry their outputs (see docs/reproduce.md).
set -euo pipefail
cd "$(dirname "$0")/.."
git config filter.nbstrip.clean "python3 tools/strip_outputs.py"
git config filter.nbstrip.smudge cat
echo "configured: filter.nbstrip.clean = $(git config --get filter.nbstrip.clean)"
echo "notebook outputs will now be stripped from commits; working copies are untouched."
