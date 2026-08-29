#!/usr/bin/env bash
# Validates skill frontmatter, registry entries, and plugin manifests.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec python3 "$HERE/scripts/validate.py" "$HERE"
