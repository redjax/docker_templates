#!/bin/bash

WEBUI_PORT="9000"
CONTAINER_NAME=
DATA_DIR=

echo ""
echo "Checking for new image"
echo ""

docker pull portainer/portainer-ce

echo ""
echo "Restarting Portainer"
echo ""

docker stop portainer && docker rm portainer

docker run -d \
    -p 8000:8000 \
    -p ${WEBUI_PORT:-9000}:9000 \
    --name=${CONTAINER_NAME:-portainer} \
    --restart=unless-stopped \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v ${DATA_DIR:-portainer_data}:/data \
    portainer/portainer-ce
