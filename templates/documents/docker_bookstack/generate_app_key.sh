#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker &>/dev/null; then
  echo "[ERROR] Docker is not installed" >&2
  exit 1
fi

OUTPUT_FILE="app_secret-DELETE-ME"

echo ""
echo "Generating Bookstack app secret"
echo ""

APP_KEY=$(docker run -it --rm --entrypoint /bin/bash lscr.io/linuxserver/bookstack:latest appkey)

echo "$APP_KEY" > "${OUTPUT_FILE}"

echo ""
echo "Secret saved to '$OUTPUT_FILE'"

