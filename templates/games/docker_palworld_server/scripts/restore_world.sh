#!/bin/bash

echo ""
echo "Restoring Palworld world backup..."
echo ""

if ! docker compose exec -it palworld restore 2>&1; then
  echo "[WARNING] Encountered an error while restoring backup of Palworld world."
  exit 1
else
  echo "Successfully restored backup Palworld world from backup."
fi
