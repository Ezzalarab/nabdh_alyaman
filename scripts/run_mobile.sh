#!/usr/bin/env bash
# Prefer a running iOS Simulator, else a running Android emulator (never macOS).
# Does not start a new Android AVD — boot iOS Simulator only when none is available.
set -euo pipefail
cd "$(dirname "$0")/.."

pick_device_id() {
  flutter devices --machine 2>/dev/null | python3 -c "
import json, sys

try:
    devices = json.load(sys.stdin)
except json.JSONDecodeError:
    sys.exit(1)

for d in devices:
    if d.get('targetPlatform') == 'ios' and d.get('emulator'):
        print(d['id'])
        sys.exit(0)

for d in devices:
    if d.get('targetPlatform') == 'android' and d.get('emulator'):
        print(d['id'])
        sys.exit(0)
"
}

DEVICE_ID="$(pick_device_id || true)"

if [[ -z "${DEVICE_ID:-}" ]]; then
  echo "No running simulator found. Opening iOS Simulator…" >&2
  open -a Simulator 2>/dev/null || true
  for _ in $(seq 1 30); do
    sleep 2
    DEVICE_ID="$(pick_device_id || true)"
    [[ -n "${DEVICE_ID:-}" ]] && break
  done
fi

if [[ -z "${DEVICE_ID:-}" ]]; then
  echo "Could not find a device." >&2
  echo "  • iOS: wait for Simulator to finish booting, or run: open -a Simulator" >&2
  echo "  • Android: start an emulator first (this script will not launch a new AVD)" >&2
  flutter devices
  exit 1
fi

echo "Running on: $DEVICE_ID" >&2
exec flutter run -d "$DEVICE_ID" "$@"
