#!/usr/bin/env bash
set -euo pipefail

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(realpath -m "$THIS_DIR/..")"

CONFIG_DIR="./config"
USERS_FILE="${CONFIG_DIR}/users"
HTPASSWD_IMAGE="httpd:2.4-alpine"

CWD=$(pwd)

function cleanup() {
    cd "$CWD"
}
trap cleanup EXIT

if [[ ! -f "${USERS_FILE}" ]]; then
    echo "ERROR: ${USERS_FILE} does not exist."
    exit 1
fi

echo "Radicale users"
cut -d: -f1 "${USERS_FILE}"
echo ""

read -rp "Enter username to change password: " USERNAME

if ! grep -q "^${USERNAME}:" "${USERS_FILE}"; then
    echo "User '${USERNAME}' not found."
    exit 1
fi

echo
echo "Enter new password for '${USERNAME}'."
echo

docker run --rm -it \
    -v "$(pwd)/${CONFIG_DIR}:/data" \
    "${HTPASSWD_IMAGE}" \
    htpasswd -B /data/users "${USERNAME}"

echo
echo "Password updated for '${USERNAME}'."

