#!/usr/bin/env bash
set -euo pipefail

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT=$(realpath -m "${THIS_DIR}/..")
CWD="$(pwd)"
trap 'cd "${CWD}"' EXIT

cd "${PROJECT_ROOT}"

echo "Pulling new container images"
if ! docker compose \
  -f compose.yml \
  -f overlays/meilisearch.yml \
  -f overlays/postgres.yml \
  -f overlays/tika.yml \
  -f overlays/valkey.yml \
  pull; then
  echo "[ERROR] Failed pulling new OpenArchiver images" >&2
  exit 1
fi

echo "Bringing stack down and restarting"
if ! docker compose \
  -f compose.yml \
  -f overlays/meilisearch.yml \
  -f overlays/postgres.yml \
  -f overlays/tika.yml \
  -f overlays/valkey.yml \
  down; then
  echo "[ERROR] Failed to bring stack down" >&2
  exit 1
fi

if ! docker compose \
  -f compose.yml \
  -f overlays/meilisearch.yml \
  -f overlays/postgres.yml \
  -f overlays/tika.yml \
  -f overlays/valkey.yml \
  up -d --force-recreate --remove-orphans; then
  echo "[ERROR] Failed to restart stack" >&2
  exit 1
fi

echo "OpenArchiver updated"

