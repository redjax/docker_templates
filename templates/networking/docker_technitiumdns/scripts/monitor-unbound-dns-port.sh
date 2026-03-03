#!/usr/bin/env bash
set -uo pipefail

if ! command -v tcpdump --help &>/dev/null; then
    echo "[ERROR] tcpdump is not installed."
    exit 1
fi

DOCKER_IP="172.16.81.10"
DNS_PORT=53

echo "Starting TCP dump on Unbound container IP ($DOCKER_IP) port $DNS_PORT"
echo ""

sudo tcpdump -i any host $DOCKER_IP and port $DNS_PORT
if [[ $? -ne 0 ]]; then
  echo ""
  echo "[ERROR] Failed monitoring Unbound DNS port."
  exit $?
fi
