#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker compose &>/dev/null; then
  echo "[ERROR] Docker is not installed."
  exit 1
fi

if [ $# -lt 1 ]; then
    echo "Usage: $0 <data_backup.tar.gz> [config_backup.tar.gz]"
    exit 1
fi

DATA_BACKUP="$1"
CONFIG_BACKUP="${2:-}"

# Check backup files exist
if [ ! -f "$DATA_BACKUP" ]; then
    echo "Error: data backup not found at $DATA_BACKUP"
    exit 1
fi
if [ -n "$CONFIG_BACKUP" ] && [ ! -f "$CONFIG_BACKUP" ]; then
    echo "Error: config backup not found at $CONFIG_BACKUP"
    exit 1
fi

echo "Stopping Davis stack if running..."
docker compose down || true

echo "Restoring Davis data volume from $DATA_BACKUP ..."
docker run --rm -v davis_data:/volume -v "$(dirname "$DATA_BACKUP")":/backup alpine \
    sh -c "rm -rf /volume/* && tar xzf /backup/$(basename "$DATA_BACKUP") -C /volume"

# Restore config/env if provided
if [ -n "$CONFIG_BACKUP" ]; then
    echo "Restoring .env file from $CONFIG_BACKUP ..."
    tar xzf "$CONFIG_BACKUP" .env
fi

echo "Restore complete!"
echo "You can now run: docker compose up -d"

