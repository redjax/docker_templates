#!/bin/bash

declare -a disallow_ports=(9000 "5140/tcp" "5140/udp" 27017 9200 9600)

echo "Closing Graylog stack ports"

for port in "${allow_ports[@]}"; do
  echo "Closing port: ${port}"
  sudo ufw deny $port
done

