#!/bin/bash

declare -a VOLUMES=("netdataconfig" "netdatalib" "netdatacache")

CONTAINER_NAME=netdata
DATA_DIR=./data

function teardown() {
    echo "Stopping & removing Netdata container: ${CONTAINER_NAME}"

    docker stop $CONTAINER_NAME
    docker rm $CONTAINER_NAME

    for vol in "${VOLUMES[@]}"; do
        echo "Removing volume ${vol} if it exists."
        docker volume rm $vol
    done

    if [[ -d ./data ]]; then
        sudo rm -r ./data
    fi
}

function main() {
    teardown
}

main
