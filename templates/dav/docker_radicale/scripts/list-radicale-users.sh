#!/usr/bin/env bash
set -euo pipefail

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(realpath -m "$THIS_DIR/..")"

USERS_FILE="${PROJECT_ROOT}/config/users"

if [[ ! -f "${USERS_FILE}" ]]; then
    echo "No users file found."
    exit 1
fi

echo "Radicale users:"
echo

cut -d: -f1 "${USERS_FILE}"

