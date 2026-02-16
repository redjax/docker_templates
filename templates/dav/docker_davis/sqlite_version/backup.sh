#!/bin/bash
set -euo pipefail

DATE=$(date +%F)  # YYYY-MM-DD
BACKUP_DIR="$(pwd)/backups"
mkdir -p "$BACKUP_DIR"

## Backup Davis data volume (includes SQLite DB)
DATA_BACKUP="$BACKUP_DIR/davis_data_backup_${DATE}.tar.gz"
echo "Backing up Davis data volume to $DATA_BACKUP "
docker run --rm -v davis_data:/volume -v "$BACKUP_DIR":/backup alpine \
    tar czf "/backup/$(basename "$DATA_BACKUP")" -C /volume .

## Backup environment file
if [ -f .env ]; then
  CONFIG_BACKUP="$BACKUP_DIR/davis_env_backup_${DATE}.tar.gz"
  echo "Backing up .env file to $CONFIG_BACKUP "
  tar czf "$CONFIG_BACKUP" .env
fi

echo "Backup completed! Files saved in $BACKUP_DIR:"
echo " - $(basename "$DATA_BACKUP")"
[ -f "$CONFIG_BACKUP" ] && echo " - $(basename "$CONFIG_BACKUP")"

