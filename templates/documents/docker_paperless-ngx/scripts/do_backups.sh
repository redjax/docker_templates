#!/bin/bash

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DB_SCRIPT="$THIS_DIR/backup-db.sh"
BACKUP_DOCUMENTS_SCRIPT="$THIS_DIR/backup-documents.sh"

if [[ ! -f "$BACKUP_DB_SCRIPT" ]]; then
    echo "[ERROR] Could not find database backup script at path: $BACKUP_DB_SCRIPT"
    exit 1
fi

if [[ ! -f "$BACKUP_DOCUMENTS_SCRIPT" ]]; then
    echo "[ERROR] Could not find documents backup script at path: $BACKUP_DOCUMENTS_SCRIPT"
    exit 1
fi
