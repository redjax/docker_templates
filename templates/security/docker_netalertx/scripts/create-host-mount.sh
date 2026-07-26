#!/usr/bin/env bash
set -euo pipefail

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_ROOT=$(realpath -m "${THIS_DIR}/..")
CWD="${PWD}"

paths=(netalertx netalertx/data netalertx/data/config netalertx/data/db)

function cleanup() {
  cd "${CWD}"
}
trap cleanup EXIT

function usage() {
  cat <<EOF
Usage: ${0} [OPTIONS]

Options:
  -h, --help    Print this help menu
  -p, --path    Path where dirs should be created
EOF
}

while [[ $# -gt 0 ]]; do
  case $1 in
  -h | --help)
    usage
    exit 0
    ;;
  -p | --path)
    CONFIG_ROOT="${2}"
    shift 2
    ;;
  *)
    echo "[ERROR] Invalid arg: $1" >&2
    echo

    usage
    exit 1
    ;;
  esac
done

mkdir -p "${CONFIG_ROOT}"

cd "${CONFIG_ROOT}"

echo "Creating paths"
for p in "${paths[@]}"; do
  _p="${CONFIG_ROOT}/${p}"
  if ! mkdir -pv "${_p}" 2>&1; then
    echo "[ERROR] Skipping path '${_p}' due to error" >&2
    continue
  fi

  echo "Create file: ${_p}/.gitkeep"
  if ! touch "${_p}/.gitkeep" 2>&1; then
    echo "[ERROR] Failed to create .gitkeep file at path ${_p}" >&2
    continue
  fi
done
