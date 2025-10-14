#!/usr/bin/env bash

set -uo pipefail

ORIGINAL_DIR=$(pwd)
THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_ROOT="$(cd "${THIS_DIR}/.." && pwd)"

cmd=(docker compose -f compose.yml -f overlays/postgres.yml)

if ! command docker compose &>/dev/null; then
    echo "[ERROR] Docker Compose is not installed."
    exit 1
fi

function cleanup() {
    cd "${ORIGINAL_DIR}"

    echo ""
    echo "Stopping containers"
    stop_cmd=("${cmd[@]}")
    stop_cmd+=(down)
}
trap cleanup EXIT

echo ""
echo "This script starts the Hoppscotch db first, then runs database migrations."
echo "You only need to do this the first time you run the stack to initialize the database."
echo ""

while true; do
    read -n 1 -r -p  "Have you edited the .env and hoppscotch.env files? (y/n) " yn

    case $yn in
        [Yy]*)
            echo ""
            echo "Proceeding."
            break
            ;;
        [Nn]*)
            echo ""
            echo ""
            echo "Copy .env.example -> .env and example.hoppscotch.env -> hoppscotch.env, and edit the values, then re-run this script."
            exit 0
            ;;
        *)
            echo ""
            echo "[WARNING] Invalid choice: $yn. Please use 'y' or 'n'"
            ;;
    esac
done

echo ""
echo "[START] Hoppscotch database initialization."

cd $TEMPLATE_ROOT

echo "Starting database container"
start_db_cmd=("${cmd[@]}")
start_db_cmd+=(up -d db)
echo "  Command: ${start_db_cmd[*]}"
echo ""

"${start_db_cmd[@]}"
if [[ $? -ne 0 ]]; then
    echo "[ERROR] Failed starting db container."
    exit $?
fi

echo ""
echo "Running database migrations"
db_migrate_cmd=("${cmd[@]}")
db_migrate_cmd+=(run --rm hoppscotch pnpm prisma migrate deploy)
echo "  Command: ${db_migrate_cmd[*]}"
echo ""

"${db_migrate_cmd[@]}"
if [[ $? -ne 0 ]]; then
    echo "[ERROR] Failed running database migrations."
    exit 1
fi

echo ""
