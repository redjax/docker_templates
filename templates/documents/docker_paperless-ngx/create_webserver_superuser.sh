#!/bin/bash

function prompt_create_env() {
    echo "Before running this script, you should copy .env.example to .env and edit it."
    read -p "Did you already create a .env file and add your values? Y/N: " create_env_choice

    case $create_env_choice in
        [Yy] | [YyEeSs])
            return 0
        ;;
        [Nn] | [NnOo])
            echo "Exiting script."

            return 1
        ;;
        *)
            echo "[ERROR] Invalid choice: ${create_env_choice}"
            prompt_create_env
        ;;
    esac
}

function create_superuser() {
    docker compose run --rm webserver createsuperuser

    return $?
}

function main() {
    prompt_create_env

    if [[ $? -eq 0 ]]; then
        create_superuser

        return $?

    else
        return $?
    fi
}

main

exit $?
