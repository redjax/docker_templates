#!/usr/bin/env bash
set -uo pipefail

if ! command -v openssl &>/dev/null; then
  echo "[ERROR] openssl is not installed."
  exit 1
fi

key=$(openssl rand -hex 32)

echo "Encryption key:"
echo "$key"
