#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "[ERROR] Docker is not installed" >&2
  exit 1
fi

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(realpath -m "${THIS_DIR}/..")"

RUNNER_IMG_TAG="${FORGEJO_RUNNER_IMG_TAG:-12}"
CONFIG_OUTPUT="${REPO_ROOT}/examples/default.runner-config.yml"

mkdir -p "$(dirname "${CONFIG_OUTPUT}")"

echo "Generating forgejo config at: ${CONFIG_OUTPUT}"
docker run --rm "data.forgejo.org/forgejo/runner:${RUNNER_IMG_TAG}" forgejo-runner generate-config > "${CONFIG_OUTPUT}"
