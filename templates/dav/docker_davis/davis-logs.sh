#!/usr/bin/env bash
set -euo pipefail

CONTAINER_LOG_PATH="/var/www/davis/var/log/prod.log"

echo "Getting Davis logs from ${CONTAINER_LOG_PATH}"
echo

docker exec -it davis tail -f "${CONTAINER_LOG_PATH}"
echo
