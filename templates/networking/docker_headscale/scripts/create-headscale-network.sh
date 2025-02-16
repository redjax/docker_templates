#!/bin/bash

## Create the network headscale & headscale-ui will talk on.

echo "[ Create Headscale Docker network ]"
echo ""

read -p "Headscale network name (default: headscale_net): " HEADSCALE_NETWORK_NAME
HEADSCALE_NETWORK_NAME=${HEADSCALE_NETWORK_NAME:-headscale_net}
echo ""

echo "Creating Headscale network: ${HEADSCALE_NETWORK_NAME}"

docker network create "${HEADSCALE_NETWORK_NAME}"
echo ""

if [[ $? -eq 0 ]]; then
    echo "[SUCCESS] Created Docker network: ${HEADSCALE_NETWORK_NAME}"
else
    echo "[ERROR] Failed creating Docker network: ${HEADSCALE_NETWORK_NAME}"
fi
