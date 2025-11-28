#!/usr/bin/env bash
set -uo pipefail

if ! command -v docker &>/dev/null; then
  echo "[ERROR] Docker is not installed."
  exit 1
fi

echo "Generating Snipe-IT app key."
echo ""

KEY=$(docker run --rm grokability/snipe-it php artisan key:generate --show)

echo ""
echo "App key:"
echo "  ${KEY}"
echo ""
echo "Paste this in your .env:"
echo "SNIPEIT_KEY=${KEY}"
echo ""
