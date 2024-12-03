#!/bin/bash

## After creating a namespace and a user, create API keys for, i.e. the headscale-ui container

echo "[ Create Headscale API Keys ]"
echo ""

docker exec headscale headscale apikeys create
echo ""

if [[ $? -eq 0 ]]; then
    echo "[SUCCESS] Created Headscale API keys"
else
    echo "[ERROR] Failed creating Headscale API keys"
fi
