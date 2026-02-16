#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR=./backups
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
## The compose.yml has `name: radicale`, and the volume's
#  name is `radicale_data`. This becomes `radicale_radicale_data`
VOLUME_NAME=radicale_radicale_data

mkdir -p "$BACKUP_DIR"

docker run --rm \
  -v ${VOLUME_NAME}:/data:ro \
  -v $(pwd)/$BACKUP_DIR:/backup \
  alpine \
  tar czf /backup/${TIMESTAMP}_radicale_backup.tar.gz -C /data .

echo "Backup created: $BACKUP_DIR/${TIMESTAMP}_radicale_backup.tar.gz"
