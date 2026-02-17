#!/usr/bin/env bash
set -euo pipefail

if ! command -v openssl &>/dev/null; then
  echo "[ERROR] OpenSSL is not installed" >&2
  exit 1
fi

OUTPUT_FILE="app_secret-DELETE-ME"

echo ""
echo "Generating Docmost app secret"
echo ""

SECRET=$(openssl rand -hex 32)

echo "$SECRET" > "$OUTPUT_FILE"

echo ""
echo "Secret saved to '$OUTPUT_FILE'"

