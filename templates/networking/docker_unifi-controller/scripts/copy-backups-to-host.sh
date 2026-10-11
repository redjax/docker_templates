#!/usr/bin/env bash
set -euo pipefail

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT=$(realpath -m "${THIS_DIR}/..")
CWD=$(pwd)
trap "cd -- ${CWD}" EXIT

## Where to put backups on the host
BACKUP_DEST="${BACKUP_DEST:-$HOME/unifi_backups}"

## Name of the service in compose
SERVICE_NAME="${SERVICE_NAME:-network-application}"

## Path to backups inside the container
CONTAINER_BACKUP_PATH="/config/data/backup"

function usage() {
  cat <<EOF
Usage:
  ${0} [OPTIONS]

Options:
  -h, --help                     Print this help menu and exit
  -o, --output-dest    <string>  Directory path on host where backups will be copied
  -p, --container-path <string>  Path in the Docker container to copy
  -n, --container-name <string>  Name of the Unifi Network Application container
EOF
}

while [[ $# -gt 0 ]]; do
  case $1 in
  -h | --help)
    usage
    exit 0
    ;;
  -o | --output-dest)
    BACKUP_DEST="${2}"
    shift 2
    ;;
  -p | --container-path)
    CONTAINER_BACKUP_PATH="${2}"
    shift 2
    ;;
  -n | --container-name)
    SERVICE_NAME="${2}"
    shift 2
    ;;
  *)
    echo "[ERROR] Invalid option: $1" >&2
    usage
    exit 1
    ;;
  esac
done

if [[ -z "${BACKUP_DEST}" ]]; then
  echo "[ERROR] Missing --output-dest" >&2
  usage
  exit 1
fi

if [[ -z "${CONTAINER_BACKUP_PATH}" ]]; then
  echo "[ERROR] Missing --container-path" >&2
  usage
  exit 1
fi

if [[ -z "${SERVICE_NAME}" ]]; then
  echo "[ERROR] Missing --container-name" >&2
  usage
  exit 1
fi

timestamp="$(date +%Y%m%d_%H%M%S)"
target_dir="$BACKUP_DEST/$timestamp"

cd "${PROJECT_ROOT}"

mkdir -p "$target_dir"

echo "Copying UniFi backups from container '$SERVICE_NAME'"
echo "  $CONTAINER_BACKUP_PATH  -->  $target_dir"

docker compose cp \
  "$SERVICE_NAME:$CONTAINER_BACKUP_PATH" \
  "$target_dir"

echo "Copied Unifi backups to '${target_dir}'"
