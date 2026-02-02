#!/usr/bin/env bash
set -uo pipefail

if ! command -v openssl &>/dev/null; then
  echo "[ERROR] openssl is not installed."
  exit 1
fi

function rand_base64() {
  local bytes="$1"
  openssl rand -base64 "$bytes" | tr -d '\n'
}

function rand_hex() {
  local bytes="$1"
  openssl rand -hex "$bytes"
}

echo ""
echo "Netbird Secrets"
echo ""
echo "-- .env file:"
echo ""
echo "PG_PASSWORD=$(rand_base64 24)"
echo "ZITADEL_DB_ADMIN_PASS=$(rand_base64 24)"
echo "ZITADEL_ADMIN_PASSWORD=$(rand_base64 20)"
echo "ZITADEL_MASTER_KEY=$(head -c32 /dev/urandom | base64 | head -c32)"
echo ""
echo "-- ./config/netbird/mannagement.json file:"
echo ""
echo "NETBIRD_DATASTORE_ENCRYPTION_KEY=$(rand_hex 32)"
echo ""
