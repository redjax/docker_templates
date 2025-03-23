#!/bin/bash

prompt_yes_no() {
    local prompt_message=$1
    local user_input
    while true; do
        read -p "$prompt_message (y/n): " user_input
        case $user_input in
            [Yy]*) echo "yes"; break ;;
            [Nn]*) echo "no"; break ;;
            *) echo "Invalid input. Please enter 'y' or 'n'." ;;
        esac
    done
}

if ! docker compose version 2>&1 > /dev/null; then
    echo "[ERROR] Docker Compose is not installed."
    exit 1
fi

## Prompt for username
read -p "Delete username: " USERNAME

## Prompt if the user should be deleted
DELETE_CONFIRM=$(prompt_yes_no "Delete user '$USERNAME'?")

if [[ $DELETE_CONFIRM == 'yes' ]]; then
    ## Confirm deletion
    DELETE_USER=$(prompt_yes_no "[CONFIRM] Delete user '$USERNAME'?")
else
    echo "User '$USERNAME' was not deleted."
    exit 2
fi

if [[ $DELETE_USER ]]; then
    docker compose exec -it ntfy ntfy user del $USERNAME
    if [[ $? -ne 0 ]]; then
        echo "[ERROR] User was not deleted: '$USERNAME'"
        exit $?
    else
        echo "Deleted user: '$USERNAME'"
        exit 0
    fi
else
    echo "User '$USERNAME' was not deleted."
    exit 2
fi
