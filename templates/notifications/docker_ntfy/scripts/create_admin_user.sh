#!/bin/bash

USERNAME=${1:-admin}
CONTAINER_NAME=${2:-ntfy}

if ! docker compose version > /dev/null 2>&1; then
    echo "[ERROR] docker compose is not installed."
    exit 1
fi

echo "[DEBUG] docker compose exec -it ntfy ntfy user add --role=admin $USERNAME"

echo "Creating user '$USERNAME'"
docker compose exec -it ntfy ntfy user add --role=admin $USERNAME

if [ $? -ne 0 ]; then
    echo "[ERROR] Failed creatinng ntfy admin user: $USERNAME"
    exit $?
else
    echo "[SUCCESS] Created ntfy admin user: $USERNAME"
    exit 0
fi
