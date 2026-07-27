#!/usr/bin/env bash

set -euo pipefail

CONFIG_DIR="./config"
EXAMPLE_CONFIG="${CONFIG_DIR}/example.config"
TARGET_CONFIG="${CONFIG_DIR}/config"
USERS_FILE="${CONFIG_DIR}/users"
IMAGE="ghcr.io/kozea/radicale:stable"

echo "[ Radicale Initial Setup ]"

## Ensure config directory exists
mkdir -p "${CONFIG_DIR}"

## Copy example config if config doesn't exist
if [[ ! -f "${TARGET_CONFIG}" ]]; then
    if [[ -f "${EXAMPLE_CONFIG}" ]]; then
        cp "${EXAMPLE_CONFIG}" "${TARGET_CONFIG}"
        echo "Created ${TARGET_CONFIG} from example.config"
    else
        echo "ERROR: ${EXAMPLE_CONFIG} not found."
        exit 1
    fi
else
    echo "${TARGET_CONFIG} already exists, skipping copy."
fi

## Prompt for username
read -rp "Enter username for first Radicale user: " USERNAME

if [[ -z "${USERNAME}" ]]; then
    echo "Username cannot be empty."
    exit 1
fi

## Prevent overwriting existing users file accidentally
if [[ -f "${USERS_FILE}" ]]; then
    echo
    read -rp "Users file already exists. Overwrite? (y/N): " CONFIRM
    if [[ ! "${CONFIRM}" =~ ^[Yy]$ ]]; then
        echo "Aborting."
        exit 1
    fi
fi

echo
echo "You will now be prompted to set a password for '${USERNAME}'."
echo

## Run htpasswd inside container
HTPASSWD_IMAGE="httpd:2.4-alpine"

docker run --rm -it \
    -v "$(pwd)/${CONFIG_DIR}:/data" \
    "${HTPASSWD_IMAGE}" \
    htpasswd -B -c /data/users "${USERNAME}"

echo
echo "Setup complete."
echo "Edit the ./config/config file to make sure the example server config is good for your needs,"
echo "then start Radicale with: docker compose up -d"

