#!/bin/bash

echo ""
echo "Backing up Palworld world..."
echo ""

if ! docker compose exec -it palworld backup 2>&1; then
  echo "[WARNING] Encountered an error while backing up Palworld world."
  exit 1
else
  echo "Successfully backed up Palworld world."
fi
