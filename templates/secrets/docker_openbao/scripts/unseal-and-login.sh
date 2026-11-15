#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="openbao"

function check_container() {
  if ! docker compose ps --services | grep -q "^${CONTAINER_NAME}$"; then
    echo "[ERROR] container '${CONTAINER_NAME}' is not running." >&2
    exit 1
  fi
}

function unseal_loop() {
  local i=1

  echo "OpenBao uses Shamir keys (e.g., 5 total, 3 required)."
  echo "Paste one key per prompt."
  echo ""

  while ((i <= 3)); do
    echo "Unsealing OpenBao with key #${i}"

    if ! docker compose exec -it "$CONTAINER_NAME" bao unseal; then
      echo "[ERROR] Unseal command failed." >&2
      return 1
    fi

    i=$((i + 1))
  done

  echo ""
  echo "Finished submitting three keys."
}

function login_root() {
  echo "Logging in with root token"
  docker compose exec -it "$CONTAINER_NAME" bao login
}

check_container

if ! login_root >&2; then
  echo "[ERROR] Failed to login with root token"
  exit 1
fi

echo ""
echo "OpenBao is ready to use"
