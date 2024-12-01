#!/bin/bash

echo ""
echo "Backing up Palworld world..."
echo ""

docker compose exec -it palworld backup

if [[ ! $? -eq 0 ]]; then
    echo "[WARNING] Encountered an error while backing up Palworld world."
    # exit $?
else
    echo "Successfully backed up Palworld world."
    # exit 0
fi
