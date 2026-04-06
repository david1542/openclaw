#!/bin/sh
set -e

CONFIG='{"gateway":{"mode":"local","controlUi":{"dangerouslyDisableDeviceAuth":true}}}'

mkdir -p /data/.openclaw

# Symlink ~/.openclaw to the persistent disk so all state survives container restarts
rm -rf /home/node/.openclaw
ln -s /data/.openclaw /home/node/.openclaw

# Only write default config if it doesn't already exist (preserve user customizations)
if [ ! -f /data/.openclaw/openclaw.json ]; then
  printf '%s' "$CONFIG" > /data/.openclaw/openclaw.json
fi

exec node dist/index.js gateway --bind lan --port 8080
