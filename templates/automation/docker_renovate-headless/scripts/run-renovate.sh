#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker &> /dev/null; then
  echo "[ERROR] docker is not installed" >&2
  exit 1
fi

if ! docker compose version >/dev/null >&2; then
  echo "[ERROR] docker compose is not available" >&2
  exit 1
fi

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT=$(realpath -m "${THIS_DIR}/..")
CWD=$(pwd -P)
trap "cd ${CWD}" EXIT

cd "${REPO_ROOT}"

echo "Running renovate container"

docker compose run --rm renovate

echo "Renovate finished"
