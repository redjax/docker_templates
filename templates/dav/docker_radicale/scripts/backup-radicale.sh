#!/usr/bin/env bash
set -euo pipefail

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(realpath -m "$THIS_DIR/..")"

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
## The compose.yml has `name: radicale`, and the volume's
#  name is `radicale_data`. This becomes `radicale_radicale_data`
VOLUME_NAME=radicale_radicale_data

CWD=$(pwd)

function cleanup() {
  cd "$CWD"
}
trap cleanup EXIT

cd "${PROJECT_ROOT}"
mkdir -p "$BACKUP_DIR"

docker run --rm \
  -v ${VOLUME_NAME}:/data:ro \
  -v $(pwd)/$BACKUP_DIR:/backup \
  alpine \
  tar czf /backup/${TIMESTAMP}_radicale_backup.tar.gz -C /data .

echo "Backup created: $BACKUP_DIR/${TIMESTAMP}_radicale_backup.tar.gz"
