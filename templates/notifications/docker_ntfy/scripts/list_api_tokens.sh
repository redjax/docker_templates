#!/bin/bash

# Function to check if Docker Compose is installed
check_docker_compose() {
  if ! docker compose version &>/dev/null; then
    echo "[ERROR] Docker Compose is not installed."
    exit 1
  fi
}

# Function to list tokens
list_tokens() {
  local username=$1
  local command="docker compose exec -it ntfy ntfy token list"

  if [[ -n "$username" ]]; then
    command+=" $username"
  fi

  echo "[INFO] Executing: $command"
  if ! "${command}" 2>&1; then
    echo "[ERROR] Failed to list tokens."
    exit 1
  fi
}

# Main script
check_docker_compose

# Prompt for username (optional)
read -r -p "Enter username (press Enter to list all tokens): " USERNAME
echo

# List tokens
list_tokens "$USERNAME"

exit 0
