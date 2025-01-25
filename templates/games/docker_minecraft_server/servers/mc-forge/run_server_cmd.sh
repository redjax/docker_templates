#!/bin/bash

CONTAINER_NAME="mc-server"
DOCKER_CMD="docker compose exec -it $CONTAINER_NAME mc-send-to-console"

read -p "Enter the Minecraft server command you want to run. Omit a leading slash (i.e. /op <player> --> op <player>): " server_cmd

CMD="$DOCKER_CMD /$server_cmd"

echo ""
echo "Executing:"
echo "  $ $CMD"
echo ""

$CMD

