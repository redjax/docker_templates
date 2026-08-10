#!/usr/bin/env bash
set -uo pipefail

if ! command -v tar &>/dev/null; then
    echo "[ERROR] tar is not installed."
    exit 1
fi

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT=$(realpath -m "$THIS_DIR/..")

BACKUP_SRC="${PROJECT_ROOT}/opengist"
BACKUP_DIR="${PROJECT_ROOT}/backups"

function ts() {
    date +"%Y%m%d%H%M%S"
}

BACKUP_FILENAME="$(ts)-opengist-backup.tar.gz"
BACKUP_DEST="${BACKUP_DIR}/${BACKUP_FILENAME}"

if [[ ! -d "$BACKUP_DIR" ]]; then
    mkdir -p "$BACKUP_DIR"
    if [[ $? -ne 0 ]]; then
        echo "[ERROR] Failed to create backup directory: ${BACKUP_DIR}"
        exit 1
    fi
fi

echo "Backing up Opengist data to path: ${BACKUP_DEST}"
echo ""

if ! tar -czf "$BACKUP_DEST" -C "$BACKUP_SRC" .; then
    echo "[ERROR] Failed to backup path '${BACKUP_SRC}' to destination '${BACKUP_DEST}'."
    exit $?
else
    echo "[SUCCESS] Created backup of Opengist data at path: ${BACKUP_DEST}"
fi
