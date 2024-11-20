#!/bin/bash

declare -a DENY_PORTS=(51821/tcp 51820/udp)

echo "Removing ports in firewall"

for port in "${DENY_PORTS[@]}"
do
    echo "DENY port: $port"
    sudo ufw deny $port
done

echo "Reloading firewall"

sudo ufw reload
