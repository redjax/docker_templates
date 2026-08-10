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
  echo "OpenBao uses Shamir keys (e.g., 5 total, 3 required)."
  echo "Paste one key per prompt."
  echo ""

  i=0
  while i <3; do
    echo "Unsealing Vault with key #${i}"
    docker compose exec -it "$CONTAINER_NAME" bao unseal
    i=$((i + 1))
  done

  echo ""
  echo "Vault is now unsealed"
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
