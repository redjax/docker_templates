#!/bin/bash

##
# NOTE:
#
# If you use ports other than the default (7778, 27015, 32330),
# make sure to update them below before running
##

ARK_STEAM_PORT=7778
ARK_STEAM_PORT_UDP=7778/udp
ARK_GAME_PORT=27015
ARK_GAME_PORT_UDP=27015/udp
ARK_RCON_PORT=32330

declare -a ALLOW_PORTS=(
    $ARK_STEAM_PORT
    $ARK_STEAM_PORT_UDP
    $ARK_GAME_PORT
    $ARK_GAME_PORT_UDP
    $ARK_RCON_PORT
)

echo "Allowing ports: ${ALLOW_PORTS[@]}"

for port in "${ALLOW_PORTS[@]}"
do
    sudo ufw allow $port
done

echo "Reloading firewall"
sudo ufw reload
