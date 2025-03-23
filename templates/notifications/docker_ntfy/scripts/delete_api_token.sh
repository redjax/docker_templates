#!/bin/bash

# Function to check if Docker Compose is installed
check_docker_compose() {
    if ! docker compose version > /dev/null 2>&1; then
        echo "[ERROR] Docker Compose is not installed."
        exit 1
    fi
}

# Function to prompt for input
prompt_input() {
    local prompt_message=$1
    local var_name=$2
    read -p "$prompt_message: " $var_name
}

# Main script
check_docker_compose

# Prompt for username
prompt_input "Enter username with token you wish to delete" USERNAME

# Prompt for token ID
prompt_input "Enter token ID to delete (see token IDs with the list_api_tokens.sh script)" TOKEN_ID

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
