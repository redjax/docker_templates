#!/bin/bash

declare -a ALLOW_PORTS=(51821/tcp 51820/udp)

echo "Allowing required ports through firewall"

for port in "${ALLOW_PORTS[@]}"
do
    echo "ALLOW port: $port"
    sudo ufw allow $port
done

echo "Reloading firewall"

sudo ufw reload
