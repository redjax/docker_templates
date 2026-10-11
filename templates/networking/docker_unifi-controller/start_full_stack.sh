#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker >&/dev/null; then
  echo "[ERROR] Docker is not installed" >&2
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "[ERROR] Docker Compose is not installed" >&2
  exit 1
fi

echo "Starting full stack (Unifi, MongoDB, Rsyslog)"
echo

docker compose -f compose.yml -f overlays/rsyslog.yml up -d
