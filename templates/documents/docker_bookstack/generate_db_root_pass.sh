#!/usr/bin/env bash
set -euo pipefail

if ! command -v openssl &>/dev/null; then
  echo "[ERROR] OpenSSL is not installed" >&2
  exit 1
fi

OUTPUT_FILE="db_root_pass-DELETE-ME"

echo ""
echo "Generating Bookstack root DB password"
echo ""

SECRET=$(openssl rand -hex 32)

echo "$SECRET" > "$OUTPUT_FILE"

echo ""
echo "Secret saved to '$OUTPUT_FILE'"

