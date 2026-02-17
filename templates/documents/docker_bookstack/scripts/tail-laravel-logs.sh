#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker compose &>/dev/null; then
  echo "[ERROR] Docker compose is not installed."
  exit 1
fi

docker compose exec -it bookstack tail -n 400 /app/www/storage/logs/laravel.log | grep '\[20' -A 3
