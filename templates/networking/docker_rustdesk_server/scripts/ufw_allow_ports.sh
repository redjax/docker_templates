#!/bin/bash

echo "Allowing RustDesk ports through UFW firewall"

for port_or_range in "21114:21119/tcp" "21116/udp"; do
  echo "  Allow $port_or_range"
  sudo ufw allow $port_or_range
  if [[ $? -ne 0 ]]; then
    echo "Failed adding $port_or_range to UFW allow rules."
  fi
done

echo "Restarting UFW"
sudo systemctl restart ufw
if [[ $? -ne 0 ]]; then
  echo "Failed restarting ufw systemctl service."
  exit $?
else
  echo "UFW restarted."
  exit 0
fi

