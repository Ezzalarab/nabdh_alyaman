#!/usr/bin/env bash
# Back-compat wrapper — use run_mobile.sh (iOS first, then running Android).
set -euo pipefail
cd "$(dirname "$0")/.."
exec "$(dirname "$0")/run_mobile.sh" "$@"
