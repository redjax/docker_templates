#!/bin/bash

set -euo pipefail

echo "Creating Forgejo data directory"
## Create data directory
if [[ ! -d "./data/forgejo" ]]; then
    echo "Creating Forgejo data directory"
    mkdir -p ./data/forgejo
fi
sudo chown -R 1000:1000 ./data/forgejo

echo "Copying example .env"
cp .env.example .env

echo "Copying example Forgejo env"
cp ./env_files/forgejo/example.env ./env_files/forgejo/default.env

echo "Copying example Traefik configs"
cp ./config/traefik/example.dynamic_config.yml ./config/traefik/dynamic_config.yml
cp ./config/traefik/example.traefik_config.yml ./config/traefik/traefik_config.yml

echo "Initial setup complete."
echo "  Make sure you edit all of the environment files & Traefik configs before running!"
