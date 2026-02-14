#!/usr/bin/env bash
set -euo pipefail

if ! command -v openssl &>/dev/null; then
  echo "[ERROR] openssl is not installed." >&2
  exit 1
fi

echo "Generating Huginn secret"
_SECRET=$(openssl rand -hex 64)
echo "${_SECRET}" >huginn_secret-DELETE-ME
echo ""
echo "Saved secret to 'huginn_secret-DELETE-ME'"

exit 0
