#!/usr/bin/env bash
set -euo pipefail

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT=$(realpath -m "${THIS_DIR}/..")
CWD=$(pwd)
trap 'cd -- "$CWD"' EXIT

echo "Listing container /var/log files"

docker compose exec -it rsyslog-collector ls /var/log
