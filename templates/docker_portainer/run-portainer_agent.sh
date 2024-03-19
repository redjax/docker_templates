#!/bin/bash

echo ""
echo "Checking for new container image"
echo ""

docker pull portainer/agent

echo ""
echo "Restarting Portainer"
echo ""

docker stop portainer-agent && docker rm portainer-agent

docker run -d \
    -p 9001:9001 \
    --name=portainer-agent \
    --restart=unless-stopped \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/lib/docker/volumes:/var/lib/docker/volumes \
    portainer/agent:latest
