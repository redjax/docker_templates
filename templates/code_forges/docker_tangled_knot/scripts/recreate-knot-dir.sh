#!/usr/bin/env bash

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_ROOT=$(realpath -m "${THIS_DIR}/..")
KNOT_ROOT="${DOCKER_ROOT}/knot"

if [[ -d "${KNOT_DIR}" ]]; then
  echo "[WARNING] Knot directory already exists: ${KNOT_ROOT}" >&2
  exit 1
else
  echo "Recreating knot/ dir"

  mkdir -p "${KNOT_ROOT}/{keys,repositories,server}"
  touch "${KNOT_ROOT}/.gitkeep"
  touch "${KNOT_ROOT}/{keys,repositories,server}/.gitkeep"
fi

