#!/bin/bash

CONTAINER_NAME="mc-server"

if ! command -v docker compose > /dev/null; then
  echo "[WARNING] Docker compose is not installed. Please install it before re-running this script."
  exit 1
fi

echo "Starting RCON CLI"
echo "Press ^C to exit"
echo ""

docker compose exec -it mc-server rcon-cli

exit $?

