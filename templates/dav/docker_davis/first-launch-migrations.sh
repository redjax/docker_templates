#!/usr/bin/env bash

if ! command -v docker compose &>/dev/null; then
  echo "[ERROR] Docker compose is not installed."
  exit 1
fi

echo ""
echo "Running Davis migrations."
echo ""

docker compose exec -it davis sh -c "APP_ENV=prod bin/console doctrine:migrations:migrate --no-interaction"

