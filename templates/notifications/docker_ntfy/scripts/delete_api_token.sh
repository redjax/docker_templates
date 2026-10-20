#!/bin/bash

# Function to check if Docker Compose is installed
check_docker_compose() {
  if ! docker compose version >/dev/null 2>&1; then
    echo "[ERROR] Docker Compose is not installed."
    exit 1
  fi
}

# Main script
check_docker_compose

# Prompt for username
read -r -p "Enter username with token you wish to delete" USERNAME
echo

# Prompt for token ID
read -r -p "Enter token ID to delete (see token IDs with the list_api_tokens.sh script)" TOKEN_ID
echo

# Build the command
COMMAND="docker compose exec -it ntfy ntfy token del $USERNAME $TOKEN_ID"

# Execute the command
echo "Executing: $COMMAND"
if eval "$COMMAND"; then
  echo "[SUCCESS] Token $TOKEN_ID deleted successfully for user: $USERNAME"
else
  echo "[ERROR] Failed to delete token $TOKEN_ID for user: $USERNAME"
  exit 1
fi
