#!/usr/bin/env bash

set -uo pipefail

ORIGINAL_DIR=$(pwd)
THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_ROOT="$(cd "${THIS_DIR}/.." && pwd)"

cmd=(docker compose -f compose.yml -f overlays/postgres.yml)

if ! command docker compose &>/dev/null; then
    echo "[ERROR] Docker Compose is not installed."
    exit 1
fi

function cleanup() {
    cd "${ORIGINAL_DIR}"
}
trap cleanup EXIT

echo ""
echo "[START] Hoppscotch + Postgres"

cd $TEMPLATE_ROOT

echo "Starting containers"
start_cmd=("${cmd[@]}")
start_cmd+=(up -d)
echo "  Command: ${start_cmd[*]}"
echo ""

"${start_cmd[@]}"
if [[ $? -ne 0 ]]; then
    echo "[ERROR] Failed starting containers."
    exit $?
fi
