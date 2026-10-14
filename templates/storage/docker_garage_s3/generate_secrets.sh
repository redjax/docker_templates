#!/usr/bin/env bash
set -euo pipefail

if ! command -v openssl &>/dev/null; then
  echo "[ERROR] openssl is not installed" >&2
  exit 1
fi

echo ""
echo "Generating Garage secrets"
echo ""

echo "  GARAGE_RPC_SECRET=$(openssl rand -hex 32)"
echo "  GARAGE_ADMIN_UI_TOKEN=$(openssl rand -base64 48)"
echo "  GARAGE_METRICS_TOKEN=$(openssl rand -base64 32)"
echo "    (this one is optional, leave empty in the .env for public access)"
echo ""
