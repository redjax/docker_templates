#!/bin/bash

set -eo pipefail

if [ "$EUID" -ne 0 ]
  then echo "Script requires elevated permissions, please re-run with sudo"
  exit 2
fi

if ! command -v ufw &> /dev/null; then
    echo "ufw is not installed, exiting.."
    exit 1
fi

GAME_PORT=9876
QUERY_PORT=9877

echo "Allowing V Rising ports $GAME_PORT and $QUERY_PORT"

ufw allow $GAME_PORT/udp
ufw allow $QUERY_PORT/udp

echo "Reloading firewall..."
ufw reload

echo "Allowed V Rising ports through UFW firewall."
exit 0
