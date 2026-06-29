#!/bin/bash

if ! docker compose version 2>&1 > /dev/null; then
    echo "[ERROR] Docker Compose is not installed."
    exit 1
fi

## Prompt for username
read -p "Enter username: " USERNAME

## Prompt for expiration period
read -p "Enter expiration period (e.g., 2d, 1w, or press Enter for no expiration): " EXPIRATION

# Build the command
COMMAND="docker compose exec -it ntfy ntfy token add"

## Add expiration if provided
if [ -n "$EXPIRATION" ]; then
    COMMAND+=" --expires=$EXPIRATION"
fi

## Prompt for label
read -p "Enter label (or press Enter for no label): " LABEL

# Add label if provided
if [ -n "$LABEL" ]; then
    COMMAND+=" --label=\"$LABEL\""
fi

## Add username
COMMAND+=" $USERNAME"

## Execute the command
echo "Executing: $COMMAND"
$COMMAND

## Check the exit status
if [ $? -eq 0 ]; then
    echo "Token created successfully for user: $USERNAME"
else
    echo "Failed to create token for user: $USERNAME"
fi
