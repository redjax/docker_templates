#!/bin/bash

if ! docker compose version 2>&1 >/dev/null; then
  echo "[ERROR] Docker Compose is not installed."
  exit 1
fi

## Prompt for username
read -r -p "Enter username: " USERNAME
echo

## Prompt for expiration period
read -r -p "Enter expiration period (e.g., 2d, 1w, or press Enter for no expiration): " EXPIRATION
echo

# Build the command
COMMAND="docker compose exec -it ntfy ntfy token add"

## Add expiration if provided
if [ -n "$EXPIRATION" ]; then
  COMMAND+=" --expires=$EXPIRATION"
fi

## Prompt for label
read -r -p "Enter label (or press Enter for no label): " LABEL
echo

# Add label if provided
if [ -n "$LABEL" ]; then
  COMMAND+=" --label=\"$LABEL\""
fi

## Add username
COMMAND+=" $USERNAME"

## Execute the command
echo "Executing: $COMMAND"
if ! "${COMMAND}" 2>&1; then
  echo "Token created successfully for user: $USERNAME"
else
  echo "Failed to create token for user: $USERNAME"
fi
