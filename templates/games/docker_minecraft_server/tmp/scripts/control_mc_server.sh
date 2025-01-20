#!/bin/bash

## RCON commands wiki:
#    https://minecraft.fandom.com/wiki/Commands

echo ""
echo "Getting running containers"
echo ""
docker ps -a

echo ""
read -p "Enter server container name (i.e. mc-server1): " mc_serv

echo ""
echo "Executing $ docker exec -i $mc_serv rcon-cli"
echo ""

docker exec -i $mc_serv rcon-cli
