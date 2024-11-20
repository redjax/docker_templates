#!/bin/bash

declare -a DENY_PORTS=(53/tcp 53/udp 8080/tcp 8080/udp 8443/tcp 3000/tcp 853/tcp 784/udp 853/udp 8853/udp 5443/tcp 5443/udp)

echo "Removing ports from firewall"

for port in "${DENY_PORTS[@]}"
do
    echo "DENY port: $port"
    sudo ufw deny $port
done

echo "Reloading firewall"

sudo ufw reload
