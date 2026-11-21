#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker compose >&2; then
  echo "[ERROR] Docker compose is not installed" >&2
  exit 1
fi

cmd=(docker compose -f compose.yml -f overlays/garage-ui.yml up -d)

echo "Running command:"
echo "  ${cmd[*]}"
echo ""

if ! "${cmd[@]}"; then
  echo "[ERROR] Failed starting Garage + webUI" >&2
  exit 1
fi

