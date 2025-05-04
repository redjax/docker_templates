#!/bin/bash

AGENT_PORT=${1:-9001}

echo ""
echo "Checking for new container image"
echo ""

docker pull portainer/agent

echo ""
echo "Restarting Portainer"
echo ""

docker stop portainer-agent && docker rm portainer-agent

docker run -d \
    -p $AGENT_PORT:$AGENT_PORT \
    --name=portainer-agent \
    --restart=unless-stopped \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/lib/docker/volumes:/var/lib/docker/volumes \
    -e AGENT_PORT=$AGENT_PORT \
    portainer/agent:latest
