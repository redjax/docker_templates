#!/bin/bash

PORT=3001
DATA_DIR=uptime-kuma
CONTAINER_NAME=uptime-kuma
VER=1

function run_container() {
    docker run -d \
        --restart=unless-stopped \
        -p ${PORT:-3001}:3001 \
        -v ${DATA_DIR:-uptime-kuma}:/app/data \
        --name ${CONTAINER_NAME:-uptime-kuma} \
        louislam/uptime-kuma:${VER:-1}
}

main() {
    run_container

    if [[ $? == 0 ]]; then
        echo "Uptime Kuma container started successfully."
    else
        echo "[ERROR]: Script encountered an error."
    fi
}

main

