#!/bin/bash

## Prompt user for concourse instance host
read -p "Your Concourse IP/Hostname (i.e. http://localhost:8080): " CONCOURSE_HOST

## Options: amd64, arm64, ...
ARCH="amd64"

PLATFORM="linux"

FLY_DOWNLOAD_URL="${CONCOURSE_HOST}/api/v1/cli?arch=${ARCH}&platform=${PLATFORM}"

echo "Downloading fly CLI from: ${FLY_DOWNLOAD_URL}"
curl ${FLY_DOWNLOAD_URL} -o fly

if [[ $? -eq 0 ]]; then
    echo "Setting executable on fly CLI"
    chmod +x ./fly
    echo "Moving fly CLI binary to /usr/local/bin"
    sudo mv ./fly /usr/local/bin/

    if [[ $? -eq 0 ]]; then
        echo "Fly v$(fly --version) installed."
    else
        echo "[ERROR] fly binary successfully moved to /usr/local/bin, but 'fly --version' command failed. Try reloading your shell with exec $SHELL"
    fi
else
    echo "[ERROR] Unable to download fly CLI from Concourse host: [${CONCOURSE_HOST}]"
fi
