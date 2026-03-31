#!/bin/sh
set -e

CONFIG='{"gateway":{"mode":"local","controlUi":{"dangerouslyDisableDeviceAuth":true}}}'

mkdir -p /data/.openclaw /home/node/.openclaw

rm -f /data/.openclaw/openclaw.json /home/node/.openclaw/openclaw.json

printf '%s' "$CONFIG" | tee /data/.openclaw/openclaw.json /home/node/.openclaw/openclaw.json > /dev/null

exec node dist/index.js gateway --bind lan --port 8080
