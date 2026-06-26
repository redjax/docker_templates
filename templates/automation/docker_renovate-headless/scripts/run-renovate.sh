#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker compose &> /dev/null; then
  echo "[ERROR] docker compose is not installed" >&2
  exit 1
fi

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT=$(realpath -m "${THIS_DIR}/..")
CWD=$(pwd -P)
trap "cd ${CWD}" EXIT

cd "${REPO_ROOT}"

echo "Running renovate container"

if ! docker compose run --rm renovate 2>&1; then
  echo "[ERROR] Failed to run renovate container" >&2
  exit 1
fi

echo "Renovate finished"
