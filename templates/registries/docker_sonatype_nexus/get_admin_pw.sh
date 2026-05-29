#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker compose &>/dev/null; then
  echo "[ERROR] docker compose is not installed" >&2
  exit 1
fi

echo "Getting Nexus password from /nexus-data/admin.password"

if ! docker compose exec -it nexus cat /nexus-data/admin.password; then
  echo "[ERROR] Failed extracting password from container volume path /nexus-data/admin.password" >&2
  exit 1
fi

echo ""

