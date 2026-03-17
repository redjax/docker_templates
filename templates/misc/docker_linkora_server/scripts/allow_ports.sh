#!/bin/bash

if ! command -v ufw &>/dev/null; then
  echo "ufw is not installed"
  exit 1
fi

echo "Allowing Linkora ports through UFW firewall"

sudo ufw allow 45454
sudo ufw allow 54545

echo "Reloading firewall to apply new rules"
sudo ufw reload

echo "Added Linkora ports (45454, 54545) to UFW allow list"

exit 0

