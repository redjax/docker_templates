#!/bin/bash

echo "Allowing RustDesk ports through UFW firewall"

for port_or_range in "21114:21119/tcp" "21116/udp"; do
  echo "  Allow $port_or_range"
  if ! sudo ufw allow $port_or_range 2>&1; then
    echo "Failed adding $port_or_range to UFW allow rules."
  fi
done

echo "Restarting UFW"
if ! sudo systemctl restart ufw 2>&1; then
  echo "Failed restarting ufw systemctl service."
  exit 1
else
  echo "UFW restarted."
  exit 0
fi
