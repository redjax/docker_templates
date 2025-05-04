#!/bin/bash
set -eo pipefail

# Configuration
VOLUME_PREFIX="vrising-server"
GAME_VOLUME="${VOLUME_PREFIX}_game_data"
CONFIG_VOLUME="${VOLUME_PREFIX}_config_data"
PERSISTENTDATA_VOLUME="${VOLUME_PREFIX}_persistent_data"
BACKUP_VOLUME="vrising-server_backup"
LOCAL_BACKUP_PATH="./backup/mnt_vrising"
BACKUP_CONTAINER="vrising_backup_container"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

## Check if docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed, exiting..."
    exit 1
fi

## Check if critical volumes exist (exit if missing)
for volume in "$GAME_VOLUME" "$PERSISTENTDATA_VOLUME" "$CONFIG_VOLUME"; do
    if ! docker volume inspect "$volume" &> /dev/null; then
        echo "Error: Docker volume '$volume' does not exist."
        exit 1
    fi
done

## Check if backup volume exists; create it if missing (optional)
if ! docker volume inspect "$BACKUP_VOLUME" &> /dev/null; then
    echo "Warning: Backup volume '$BACKUP_VOLUME' does not exist. Creating it now..."
    docker volume create "$BACKUP_VOLUME"
fi

## Remove any existing backup container
echo "Removing existing backup container if it exists..."
docker rm -f "$BACKUP_CONTAINER" 2>/dev/null || true

## Start backup container with correct volume mounts
echo "Starting backup container..."
docker run -d --name "$BACKUP_CONTAINER" \
    -v "${GAME_VOLUME}:/mnt/vrising/server:ro" \
    -v "${CONFIG_VOLUME}:/mnt/vrising/server/VRisingServer_Data:ro" \
    -v "${PERSISTENTDATA_VOLUME}:/mnt/vrising/persistentdata:ro" \
    -v "${BACKUP_VOLUME}:/backup" \
    -v "${LOCAL_BACKUP_PATH}:/local_backup" \
    alpine sleep infinity

## Wait a few seconds to ensure container is up
sleep 3

## Install rsync inside the backup container
echo "Installing rsync in backup container..."
docker exec "$BACKUP_CONTAINER" sh -c "apk update && apk add --no-cache rsync"

## Create timestamped backup directories inside backup volume
echo "Creating backup directories inside backup volume..."
docker exec "$BACKUP_CONTAINER" sh -c "mkdir -p /backup/${TIMESTAMP}/server /backup/${TIMESTAMP}/persistentdata /backup/${TIMESTAMP}/VRisingServer_Data"

## Copy data from mounted volumes to backup volume
echo "Copying server files to backup volume..."
docker exec "$BACKUP_CONTAINER" sh -c "cp -a /mnt/vrising/server/. /backup/${TIMESTAMP}/server/"
docker exec "$BACKUP_CONTAINER" sh -c "cp -a /mnt/vrising/persistentdata/. /backup/${TIMESTAMP}/persistentdata/"
docker exec "$BACKUP_CONTAINER" sh -c "cp -a /mnt/vrising/server/VRisingServer_Data/. /backup/${TIMESTAMP}/VRisingServer_Data/"

## Sync backup volume contents to local backup path
echo "Syncing backup volume to local backup directory..."
docker exec "$BACKUP_CONTAINER" sh -c "rsync -a /backup/${TIMESTAMP} /local_backup/"

## Stop and remove backup container
echo "Cleaning up backup container..."
docker stop "$BACKUP_CONTAINER"
docker rm "$BACKUP_CONTAINER"

echo "Backup completed successfully! Backup timestamp: $TIMESTAMP"
echo "Backup files are available at: ${LOCAL_BACKUP_PATH}/${TIMESTAMP}"

exit 0
