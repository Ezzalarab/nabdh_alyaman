#!/usr/bin/env bash
# Print Flutter device id for launch.json (iOS simulator first, then running Android).
set -euo pipefail
cd "$(dirname "$0")/.."
flutter devices --machine 2>/dev/null | python3 -c "
import json, sys
devices = json.load(sys.stdin)
for d in devices:
    if d.get('targetPlatform') == 'ios' and d.get('emulator'):
        print(d['id']); sys.exit(0)
for d in devices:
    if d.get('targetPlatform') == 'android' and d.get('emulator'):
        print(d['id']); sys.exit(0)
print('No iOS/Android simulator found. Run: flutter devices', file=sys.stderr)
sys.exit(1)
"
