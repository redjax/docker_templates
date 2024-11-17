#!/bin/bash

echo "Allowing Enshrouded game server ports"

sudo ufw allow 15636/udp
sudo ufw allow 15636/tcp
sudo ufw allow 15637/udp
sudo ufw allow 15637/tcp

echo "Reloading firewall"

sudo ufw reload
