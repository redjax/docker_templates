#!/usr/bin/env bash
set -euo pipefail

USERS_FILE="./config/users"

if [[ ! -f "${USERS_FILE}" ]]; then
    echo "No users file found."
    exit 1
fi

echo "Radicale users:"
echo

cut -d: -f1 "${USERS_FILE}"

