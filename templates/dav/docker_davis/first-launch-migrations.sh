#!/usr/bin/env bash

if ! command -v docker compose &>/dev/null; then
  echo "[ERROR] Docker compose is not installed."
  exit 1
fi

echo ""
echo "Running Davis migrations."
echo ""

# docker compose run --rm davis \
#   sh -c "mkdir -p /data /data/var && chown -R 82:82 /data && bin/console doctrine:migrations:migrate --no-interaction"

docker compose run --rm davis sh -c '
  mkdir -p /data /data/var &&
  mkdir -p /webdav/public /webdav/homes /tmp &&
  chown -R 82:82 /data /webdav &&
  bin/console doctrine:migrations:migrate --no-interaction &&
  chown -R 82:82 /data /webdav
'
