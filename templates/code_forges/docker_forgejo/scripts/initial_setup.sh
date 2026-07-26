#!/bin/bash

set -euo pipefail

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT=$(realpath -m "${THIS_DIR}/..")
PROJECT_CONFIG_DIR="${PROJECT_ROOT}/config"
PROJECT_DATA_DIR="${PROJECT_ROOT}/data"

FORGEJO_DATA_DIR="${PROJECT_ROOT}/data"
CHMOD_UID="1000"
CHMOD_GID="1000"

function usage() {
  cat <<EOF
Usage: ${0} [OPTIONS]

Options:
  -h, --help             Print this help menu
  -d, --data-dir <path>  Host volume mount for Forgejo data
  -u, --user-id  <int>   UUID for permissions. Default: 1000
  -g, --group-id <int>   GUID for permissions. Default: 1000

EOF
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--data-dir)
      FORGEJO_DATA_DIR="$2"
      shift 2
      ;;
    -u|--user-id)
      CHMOD_UID="$2"
      shift 2
      ;;
    -g|--group-id)
      CHMOD_GID="$2"
      shift 2
      ;;
    *)
      echo "[ERROR] Invalid arg: $1" >&2
      usage
      exit 1
  esac
done

## Create data directory
if [[ ! -d "${FORGEJO_DATA_DIR}" ]]; then
    echo "Creating Forgejo data directory: ${FORGEJO_DATA_DIR}"
    mkdir -p "${FORGEJO_DATA_DIR}"
else
  echo "Forgejo data directory already exists"
fi

sudo chown -R $CHMOD_UID:$CHMOD_GID "${FORGEJO_DATA_DIR}"

if [[ ! -f "${PROJECT_ROOT}/.env" ]]; then
  echo "Copying example .env"
  cp "${PROJECT_ROOT}/.env.example" "${PROJECT_ROOT}/.env"
else
  echo "Docker .env file already exists"
fi

if [[ ! -f "${PROJECT_ROOT}/env_files/forgejo/default.env" ]]; then
  echo "Copying example Forgejo env"
  cp "${PROJECT_ROOT}/env_files/forgejo/example.env ${PROJECT_ROOT}/env_files/forgejo/default.env"
else
  echo "Forgejo default env file already exists"
fi

if [[ ! -f "${PROJECT_CONFIG_DIR}/traefik/dynamic_config.yml" ]]; then
  echo "Copying example Traefik dynamic config"
  cp ${PROJECT_CONFIG_DIR}/traefik/example.dynamic_config.yml ${PROJECT_CONFIG_DIR}/traefik/dynamic_config.yml
else
  echo "Traefik dynamic config already exists"
fi

if [[ ! -f "${PROJECT_CONFIG_DIR}/traefik/dynamic_config.yml" ]]; then
  cp ${PROJECT_CONFIG_DIR}/traefik/example.traefik_config.yml ${PROJECT_CONFIG_DIR}/traefik/traefik_config.yml
else
  echo "Traefik config already exists"
fi

echo
echo "Initial setup complete."
echo "Make sure you edit all of the environment files & Traefik configs before running!"

