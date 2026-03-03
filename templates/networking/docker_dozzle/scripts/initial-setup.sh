#!/usr/bin/env bash
set -uo pipefail

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PROJECT_ROOT="${THIS_DIR}/.."
LOGS_DIR="${PROJECT_ROOT}/logs"
CONFIG_DIR="${PROJECT_ROOT}/config"
SCRIPTS_DIR="${PROJECT_ROOT}/scripts"

if ! command -v docker &>/dev/null; then
    echo "[ERROR] Docker is not installed."
    exit 1
fi

if [[ ! -f "${PROJECT_ROOT}/.env" ]]; then
    echo "${PROJECT_ROOT}/.env does not exist. Copying default from ${PROJECT_ROOT}/example.env"

    cp "${PROJECT_ROOT}/example.env" "${PROJECT_ROOT}/.env"

    echo ""
    echo "Don't forget to edit .env!"
fi

if [[ ! -f "${CONFIG_DIR}/users.yml" ]]; then
    echo "${CONFIG_DIR}/users.yml does not exist. Copying default from ${CONFIG_DIR}/example.users.yml"

    cp "${CONFIG_DIR}/example.users.yml" "${CONFIG_DIR}/users.yml"

    echo ""
    echo "Don't forget to edit users.yml! You can use ${SCRIPTS_DIR}/generate-dozzle-user.sh to create the user YAML to add to users.yml"
    echo ""
fi

if [[ ! -f "${LOGS_DIR}/dozzle.log" ]]; then
    echo "Creating initial log file: ${LOGS_DIR}/dozzle.log"

    mkdir -p "${LOGS_DIR}"
    touch "${LOGS_DIR}/dozzle.log"
fi

## -----------

echo ""
echo "Setup finished. Make sure to edit the .env file and config/users.yml before running docker compose up -d."
exit 0
