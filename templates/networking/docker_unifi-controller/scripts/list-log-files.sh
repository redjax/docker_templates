#!/usr/bin/env bash
set -euo pipefail

CWD=$(pwd)
trap 'cd -- "$CWD"' EXIT

echo "Listing container /var/log files"

docker compose exec -it rsyslog-collector ls /var/log
