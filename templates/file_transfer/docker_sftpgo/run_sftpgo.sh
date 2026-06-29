#!/bin/bash

##
# This script spins up a quick SFTPGo container.
# Pass a path on the host as an arg to mount it in the SFTPGo container.
##

HOST_PATH=$1

if [ -z "$HOST_PATH" ]; then
    echo "Usage: $0 /path/on/host"
    exit 1
fi

echo "Starting SFTPGo container using path: $HOST_PATH"

docker run --name sftpgo \
    -p 8080:8080 \
    -p 2022:2022 \
    -e SFTPGO_GRACE_TIME=32 \
    -v $HOST_PATH:/srv/sftpgo \
    -d \
    "drakkan/sftpgo:latest"

if [[ $? -ne 0 ]]; then
    echo "Failed to start SFTPGo container"
    exit 1
fi
