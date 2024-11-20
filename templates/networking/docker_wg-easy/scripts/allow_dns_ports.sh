#!/bin/bash

declare -a ALLOW_PORTS=(53/tcp 53/udp 8080/tcp 8080/udp 8443/tcp 3000/tcp 853/tcp 784/udp 853/udp 8853/udp 5443/tcp 5443/udp)

echo "Allowing required ports through firewall"

for port in "${ALLOW_PORTS[@]}"
do
    echo "ALLOW port: $port"
    sudo ufw allow $port
done

echo "Reloading firewall"

sudo ufw reload
