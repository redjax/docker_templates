#!/usr/bin/env bash
set -euo pipefail

if ! command -v openssl >&/dev/null; then
  echo "[ERROR] OpenSSL is not installed" >&2
  exit 1
fi

echo "HOMEBOX_API_KEY_PEPPER=$(openssl rand -hex 32)"

