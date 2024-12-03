#!/bin/bash

## Before running Headscale, you need to create a namespace (similar to an account in Tailscale).
#  This script helps with that process.
#
#  https://techoverflow.net/2022/02/01/how-to-create-namespace-on-headscale-server/

echo "[ Create Headscale Namespace ]"
echo ""

read -p "What namespace do you want to use for Headscale? " HEADSCALE_NAMESPACE
echo ""
echo "Setting Headscale namespace to: ${HEADSCALE_NAMESPACE}"
echo ""

docker compose exec headscale headscale namespaces create "${HEADSCALE_NAMESPACE}"
echo ""

if [[ $? -eq 0 ]]; then
    echo "[SUCCESS] Created Headscale namespace: ${HEADSCALE_NAMESPACE}"
else
    echo "[ERROR] Error creating Headscale namespace: ${HEADSCALE_NAMESPACE}"
fi
