#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <backup-file.tar.gz>"
  exit 1
fi

BACKUP_FILE="$1"
VOLUME_NAME="radicale_radicale_data"

if [ ! -f "$BACKUP_FILE" ]; then
  echo "Backup file not found: $BACKUP_FILE"
  exit 1
fi

docker compose down

echo "Restoring $BACKUP_FILE into volume $VOLUME_NAME"

docker run --rm \
  -v ${VOLUME_NAME}:/data \
  -v $(pwd):/backup \
  alpine \
  sh -c "rm -rf /data/* && tar xzf /backup/${BACKUP_FILE} -C /data"

echo "Restore complete"
docker compose up -d
