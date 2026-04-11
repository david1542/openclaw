#!/bin/sh
set -e

CONFIG='{"gateway":{"mode":"local","controlUi":{"dangerouslyDisableDeviceAuth":true}}}'

mkdir -p /data/.openclaw /data/.local

# Symlink ~/.openclaw and ~/.local to the persistent disk so all state survives container restarts
rm -rf /home/node/.openclaw /home/node/.local
ln -s /data/.openclaw /home/node/.openclaw
ln -s /data/.local /home/node/.local

# Only write default config if it doesn't already exist (preserve user customizations)
if [ ! -f /data/.openclaw/openclaw.json ]; then
  printf '%s' "$CONFIG" > /data/.openclaw/openclaw.json
fi

# Remove references to plugins whose paths don't exist on disk
if command -v python3 > /dev/null 2>&1; then
  python3 -c "
import json, os
try:
    with open('/data/.openclaw/openclaw.json') as f:
        c = json.loads(f.read())
    changed = False
    paths = c.get('plugins', {}).get('load', {}).get('paths', [])
    missing = [p for p in paths if not os.path.isdir(p)]
    if missing:
        c['plugins']['load']['paths'] = [p for p in paths if os.path.isdir(p)]
        if not c['plugins']['load']['paths']:
            del c['plugins']['load']
        for p in missing:
            name = os.path.basename(p)
            if name in c.get('plugins', {}).get('entries', {}):
                del c['plugins']['entries'][name]
        changed = True
    if changed:
        with open('/data/.openclaw/openclaw.json', 'w') as f:
            json.dump(c, f, indent=2)
        print('[entrypoint] removed missing plugin paths: ' + ', '.join(missing))
except Exception as e:
    print('[entrypoint] plugin cleanup skipped: ' + str(e))
" 2>&1
fi

exec node dist/index.js gateway --bind lan --port 8080