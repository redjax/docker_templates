#!/usr/bin/env bash

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${THIS_DIR}/.." && pwd)"

ORIGINAL_DIR=$(pwd)

if ! command -v uv &>/dev/null; then
  echo "[ERROR] uv is not installed"
  exit 1
fi

function cleanup() {
  cd "$ORIGINAL_DIR" || return
}
trap cleanup EXIT

echo ""
echo "Upgrading package lockfile with uv lock --upgrade"
echo ""

cd "${REPO_ROOT}" || exit 1

uv lock --upgrade
uv_exit_status="${?}"

if [[ "${uv_exit_status}" -ne 0 ]]; then
  echo "[ERROR] Failed updating lockfile"
  exit "${uv_exit_status}"
fi
