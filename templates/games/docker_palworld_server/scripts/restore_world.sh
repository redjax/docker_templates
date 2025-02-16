#!/bin/bash

echo ""
echo "Restoring Palworld world backup..."
echo ""

docker compose exec -it palworld restore

if [[ ! $? -eq 0 ]]; then
    echo "[WARNING] Encountered an error while restoring backup of Palworld world."
    # exit $?
else
    echo "Successfully restored backup Palworld world from backup."
    # exit 0
fi
