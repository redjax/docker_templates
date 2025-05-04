#!/bin/bash

CONTAINER_NAME="vrising-server"
BACKUP_VOLUME_NAME="vrising_server_backup"
LOCAL_BACKUP_PATH="./backup/mnt_vrising"

if ! command -v docker &> /dev/null; then
    echo "docker is not installed, exiting.."
    exit 1
fi

echo "Removing existing backup container if it exists"
docker rm -f vrising_backup_container

if [[ $? -eq 0 ]]; then
    echo "Backup container removed successfully"
else
    echo "Failed to remove backup container. Continuing anyway."
fi

echo "Starting backup container."

docker run --name vrising_backup_container \
    -v "${CONTAINER_NAME}:/mnt/vrising" \
    -v "${BACKUP_VOLUME_NAME}:/backup" \
    -v "${LOCAL_BACKUP_PATH}:/local_backup" \
    alpine sleep infinity &

if [[ ! $? -eq 0 ]]; then
    echo "Failed to start backup container."
    exit 1
fi

## Wait for container to start
sleep 2

## Copy files from /mnt/vrising to backup volume
docker exec vrising_backup_container sh -c "cp -r /mnt/vrising/* /backup/"

if [[ ! $? -eq 0 ]]; then
    echo "Failed to copy files from /mnt/vrising to backup volume."

    docker stop vrising_backup_container
    docker rm vrising_backup_container

    exit 1
fi

## Stop and remove backup container
docker stop vrising_backup_container
docker rm vrising_backup_container

if [[ $? -eq 0 ]]; then
    echo "Backup completed successfully. V Rising server data copied to ${LOCAL_BACKUP_PATH}"

    exit 0
else
    echo "Failed to stop and remove backup container."
    exit 1
fi
