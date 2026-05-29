#!/usr/bin/env bash
set -euo pipefail

if ! command -v openssl >& /dev/null; then
  echo "[ERROR] openssl is not installed" >&2
  exit 1
fi

echo ""
echo "[ Hawser agent token ]"
openssl rand -base64 32 | tr '+/' '-_' | tr -d '='
echo ""
echo "Paste this value in the HAWSER_TOKEN env var"
echo ""

