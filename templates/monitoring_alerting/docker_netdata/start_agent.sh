#!/bin/bash

CONTAINER_NAME=netdata
## nightly,  stable
RELEASE=stable

function start_agent() {
    CONTAINER_HOSTNAME=$(hostname)
    read -p "Claim token: " CLAIM_TOKEN
    read -p "Room IDs: " ROOM_IDS

    docker run -d --name=netdata \
        -p 19999:19999 \
        --hostname $CONTAINER_HOSTNAME \
        -v netdataconfig:/etc/netdata \
        -v netdatalib:/var/lib/netdata \
        -v netdatacache:/var/cache/netdata \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v /etc/passwd:/host/etc/passwd:ro \
        -v /etc/group:/host/etc/group:ro \
        -v /proc:/host/proc:ro \
        -v /sys:/host/sys:ro \
        -v /etc/os-release:/host/etc/os-release:ro \
        --restart unless-stopped \
        --cap-add SYS_PTRACE \
        --security-opt apparmor=unconfined \
        -e NETDATA_CLAIM_TOKEN=$CLAIM_TOKEN \
        -e NETDATA_CLAIM_URL=https://app.netdata.com \
        -e NETDATA_CLAIM_ROOMS=$ROOM_IDS \
        netdata/netdata:$RELEASE
}

function start_agent_compose() {

    cd agent

    docker compose up -d

}

function main() {
    # start_agent
    start_agent_compose
}

main
