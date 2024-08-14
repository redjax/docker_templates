#!/bin/bash

CONTAINER_NAME="unifi-controller"

docker run -d \
    --name watchtower \
    -v /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower $CONTAINER_NAME --debug

