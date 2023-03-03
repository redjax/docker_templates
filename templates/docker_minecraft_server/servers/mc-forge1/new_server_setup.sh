#!/bin/bash

declare -a create_dirs=("./data" "./worlds" "./plugins")

for d in ${create_dirs[@]}; do
    if [ ! -d "$d" ]; then
        echo "Creating directory: $d"
        mkdir -pv "$d"
    else
        echo "Directory exists, skipping: $d"
    fi
done

if [ ! -f ".env" ]; then
    echo "Copying .env.example to .env"
    cp .env.example .env
else
    echo "Skipping .env.example copy, .env file already exists"
fi

echo ""
echo "Setup complete."
echo "Instructions:"
echo "  - Edit .env file with desired configuration"
echo "  - Run $ docker compose up -d"
echo "  - Check server logs with $ docker compose logs -f mc-server"
