#!/bin/bash

set -e

## Create data directory
if [[ ! -d "./data/forgejo" ]]; then
    echo "Creating Forgejo data directory"
    mkdir -p ./data/forgejo
fi

sudo chown -R 1000:1000 ./data/forgejo
