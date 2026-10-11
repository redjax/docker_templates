#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker compose >&/dev/null; then
  echo "[ERROR] docker compose is not installed" >&2
  exit 1
fi

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT=$(realpath -m "${THIS_DIR}/..")
CWD="$(pwd)"
trap 'cd "${CWD}"' EXIT

cd "${PROJECT_ROOT}"

echo
echo "Updating Pangolin containers"
docker compose pull && docker compose up -d --force-recreate

