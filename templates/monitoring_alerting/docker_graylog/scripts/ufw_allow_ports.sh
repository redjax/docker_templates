#!/bin/bash

declare -a allow_ports=(9000 "5140/tcp" "5140/udp" 27017 9200 9600)

echo "Allowing Graylog stack ports"

for port in "${allow_ports[@]}"; do
  echo "Allowing port: ${port}"
  sudo ufw allow $port
done

