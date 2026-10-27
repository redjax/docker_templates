#!/usr/bin/env bash
set -euo pipefail

command -v openssl >/dev/null 2>&1 || {
  echo "Error: openssl is required." >&2
  exit 1
}

echo "# Generated DefectDojo secrets"
echo "DD_DATABASE_PASSWORD=$(openssl rand -hex 24)"
echo "DD_SECRET_KEY=$(openssl rand -hex 32)"
echo "DD_CREDENTIAL_AES_256_KEY=$(openssl rand -hex 16)"
