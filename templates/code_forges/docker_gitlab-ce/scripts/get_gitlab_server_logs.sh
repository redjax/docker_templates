#!/bin/bsh

if ! command -v docker &>/dev/null; then
    echo "[ERROR] Docker is not installed."
    exit 1
fi

docker logs -f gitlab-server
