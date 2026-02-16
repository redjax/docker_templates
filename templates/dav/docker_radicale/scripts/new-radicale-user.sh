#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="./config"
USERS_FILE="${CONFIG_DIR}/users"
HTPASSWD_IMAGE="httpd:2.4-alpine"

if [[ ! -f "${USERS_FILE}" ]]; then
    echo "ERROR: ${USERS_FILE} does not exist."
    echo "Run init-setup.sh first."
    exit 1
fi

read -rp "Enter new username: " USERNAME

if [[ -z "${USERNAME}" ]]; then
    echo "Username cannot be empty."
    exit 1
fi

echo
echo "You will now set a password for '${USERNAME}'."
echo

docker run --rm -it \
    -v "$(pwd)/${CONFIG_DIR}:/data" \
    "${HTPASSWD_IMAGE}" \
    htpasswd -B /data/users "${USERNAME}"

echo
echo "User '${USERNAME}' added or updated."

