#!/usr/bin/env bash
set -Eeuo pipefail

if ! command -v docker compose >&/dev/null; then
  echo "[ERROR] docker compose is not installed" >&2
  exit 1
fi

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT=$(realpath -m "${THIS_DIR}/..")

CWD="$(pwd)"
trap 'cd "${CWD}"' EXIT

COMPOSE_FILES=(compose.yml overlays/postgres.yml)

cd "${PROJECT_ROOT}"
echo "Updating Netbird stack"

CMD=(docker compose)

for f in "${COMPOSE_FILES[@]}"; do
  CMD+=(-f "${f}")
done

PULL_CMD=("${CMD[@]}")
PULL_CMD+=(pull)

UP_CMD=("${CMD[@]}")
UP_CMD+=(up -d --force-recreate)

echo
echo "Pulling containers"
echo "  Command: ${PULL_CMD[*]}"
"${PULL_CMD[@]}"

echo
echo "Restarting container stack"
echo "  Command: ${UP_CMD[@]}"
"${UP_CMD[@]}"

