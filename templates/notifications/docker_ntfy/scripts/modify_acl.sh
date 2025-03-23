#!/bin/bash

## Function to check if Docker Compose is installed
check_docker_compose() {
    if ! docker compose version > /dev/null 2>&1; then
        echo "[ERROR] Docker Compose is not installed."
        exit 1
    fi
}

## Function to prompt for input
prompt_input() {
    local prompt_message=$1
    local var_name=$2
    read -p "$prompt_message: " $var_name
}

## Main script
check_docker_compose

## Prompt for username (or "everyone" for anonymous access)
prompt_input "Enter username (or 'everyone' for anonymous access)" USERNAME

## Prompt for topic name (wildcards like "up*" are allowed)
prompt_input "Enter topic name (e.g., 'mytopic' or 'up*')" TOPIC

## Prompt for access level (e.g., 'read', 'write', or 'rw')
while true; do
    read -p "Enter access level ('read', 'write', 'rw', or 'deny'): " ACCESS_LEVEL
    case $ACCESS_LEVEL in
        read|write|rw|deny) break ;;
        *) echo "Invalid access level. Please enter 'read', 'write', 'rw', or 'deny'." ;;
    esac
done

## Build the command
COMMAND="docker compose exec -it ntfy ntfy access $USERNAME \"$TOPIC\" $ACCESS_LEVEL"

## Execute the command
echo "Executing: $COMMAND"
if eval "$COMMAND"; then
    echo "[SUCCESS] Granted $ACCESS_LEVEL access to topic '$TOPIC' for user: $USERNAME"
else
    echo "[ERROR] Failed to grant access to topic '$TOPIC' for user: $USERNAME"
    exit 1
fi

exit 0
