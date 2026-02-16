#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="./config"
USERS_FILE="${CONFIG_DIR}/users"
HTPASSWD_IMAGE="httpd:2.4-alpine"

if [[ ! -f "${USERS_FILE}" ]]; then
    echo "ERROR: ${USERS_FILE} does not exist."
    exit 1
fi

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

