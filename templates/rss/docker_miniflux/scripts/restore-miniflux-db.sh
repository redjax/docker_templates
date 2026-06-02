#!/bin/bash
set -euo pipefail

####################################################################
# Restores a database dump to the running database                 #
#                                                                  #
# Assumes you are running the local overlays/postgres.yml overlay. #
#                                                                  #
# If you are using a database on another host, you may need to     #
# modify the command and run it manually.                          #
####################################################################

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
DOCKER_ROOT=$(realpath -m "${THIS_DIR}/..")
RESTART_CONTAINERS="false"

cd "${DOCKER_ROOT}"

## Load .env file if it exists
ENV_FILE="${ENV_FILE:-.env}"
if [ -f "$ENV_FILE" ]; then
    ## Load variables from .env, exporting only valid shell variable names
    while IFS='=' read -r key value || [ -n "$key" ]; do
        ## Skip comments and empty lines
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        
        ## Remove leading/trailing whitespace and quotes
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | sed 's/^["'"'"']//;s/["'"'"']$//')
        
        ## Export if not already set via environment or command line
        case "$key" in
            PG_USER|PG_DB|PG_PASSWORD|ADMIN_USERNAME|ADMIN_PASSWORD|CREATE_ADMIN|RUN_MIGRATIONS|BASE_URL|POLLING_FREQUENCY|MINIFLUX_HTTP_PORT|MINIFLUX_IMG_TAG|PG_IMG_TAG|PG_HOST|PG_PORT)
                export "$key"="$value"
                ;;
        esac
    done < "$ENV_FILE"
fi

## Configuration defaults
COMPOSE_FILE="${COMPOSE_FILE:-compose.yml}"
POSTGRES_OVERLAY="${POSTGRES_OVERLAY:-overlays/postgres.yml}"
PG_USER="${PG_USER:-miniflux}"
PG_DB="${PG_DB:-miniflux}"

## Usage function
function usage() {
  cat <<EOF
Usage: $0 [OPTIONS] BACKUP_FILE

Restore Miniflux PostgreSQL database from a backup file.

Options:
  --compose-file     PATH  Compose file (default: compose.yml)
  --postgres-overlay PATH  Postgres overlay file (default: overlays/postgres.yml)
  --pg-user          USER  PostgreSQL user (default: miniflux)
  --pg-db            NAME  PostgreSQL database (default: miniflux)
  --drop-db                Drop and recreate database before restore (dangerous!)
  --restart                Restart Miniflux container after backup
  --kill-connections       Kill all active connections before dropping database
  -h, --help               Show this help message

Arguments:
  BACKUP_FILE              Path to backup file (.sql or .sql.gz)

Examples:
  $0 backups/miniflux_20260601_020000.sql.gz
  $0 --pg-user myuser --pg-db mydb /path/to/backup.sql
  $0 --drop-db backups/miniflux_20260601_020000.sql.gz
EOF
}

## Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --compose-file)
            COMPOSE_FILE="$2"
            shift 2
            ;;
        --postgres-overlay)
            POSTGRES_OVERLAY="$2"
            shift 2
            ;;
        --pg-user)
            PG_USER="$2"
            shift 2
            ;;
        --pg-db)
            PG_DB="$2"
            shift 2
            ;;
        --restart)
          RESTART_CONTAINERS="true"
          shift
          ;;
        --drop-db)
            DROP_DB=1
            shift
            ;;
        --kill-connections)
            KILL_CONNECTIONS=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            echo "Error: Unknown option: $1" >&2
            echo "Use --help for usage information" >&2
            exit 1
            ;;
        *)
            BACKUP_FILE="$1"
            shift
            ;;
    esac
done

## Validate BACKUP_FILE is provided
if [ -z "${BACKUP_FILE:-}" ]; then
    echo "Error: BACKUP_FILE is required" >&2
    echo "Use --help for usage information" >&2
    exit 1
fi

## Validate PG_PASSWORD is set (required for psql)
if [ -z "${PG_PASSWORD:-}" ]; then
    echo "Error: PG_PASSWORD is not set" >&2
    echo "Set it in .env file or export PG_PASSWORD before running" >&2
    exit 1
fi

## Validate backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Backup file not found: $BACKUP_FILE" >&2
    exit 1
fi

## Determine if backup is compressed
if [[ "$BACKUP_FILE" == *.gz ]]; then
    DECOMPRESS="gzip -dc"
    echo "Detected compressed backup (.sql.gz)"
else
    DECOMPRESS="cat"
    echo "Detected uncompressed backup (.sql)"
fi

echo "Restoring Miniflux database"
echo "Backup file: $BACKUP_FILE"
echo "Database: ${PG_USER}@${PG_DB}"

## Helper function to handle database access errors
function handle_db_access_error() {
    echo ""
    echo "ERROR: Database \"$PG_DB\" is being accessed by other users"
    echo ""
    echo "To fix this, stop the miniflux container before restoring:"
    echo ""
    echo "  docker compose -f $COMPOSE_FILE -f $POSTGRES_OVERLAY stop miniflux"
    echo ""
    echo "Then run the restore again:"
    echo ""
    echo "  $0 --drop-db $BACKUP_FILE"
    echo ""
    echo "Alternatively, use --kill-connections to forcibly terminate active connections:"
    echo ""
    echo "  $0 --drop-db --kill-connections $BACKUP_FILE"
    echo ""
    exit 1
}

echo
echo "Ensuring Miniflux container is stopped"
echo

docker compose -f $COMPOSE_FILE -f $POSTGRES_OVERLAY stop miniflux

## Optionally drop and recreate database
if [ "${DROP_DB:-}" = "1" ]; then
    echo "Dropping and recreating database"
    
    # Kill active connections if requested
    if [ "${KILL_CONNECTIONS:-}" = "1" ]; then
        echo "Killing active connections to ${PG_DB}"
        docker compose -f "$COMPOSE_FILE" -f "$POSTGRES_OVERLAY" exec -T -e PGPASSWORD="$PG_PASSWORD" db psql -U "$PG_USER" -d postgres -c "
            SELECT pg_terminate_backend(pid) 
            FROM pg_stat_activity 
            WHERE datname = '${PG_DB}' AND pid <> pg_backend_pid();
        " || true
    fi
   
    # Connect to 'postgres' database to drop the target database
    if ! docker compose -f "$COMPOSE_FILE" -f "$POSTGRES_OVERLAY" exec -T -e PGPASSWORD="$PG_PASSWORD" db psql -U "$PG_USER" -d postgres -c "DROP DATABASE IF EXISTS ${PG_DB};" 2>&1 | tee /dev/stderr | grep -q "cannot drop"; then
        : # Success or already dropped
    elif [ "${KILL_CONNECTIONS:-}" != "1" ]; then
        handle_db_access_error
    fi
    
    docker compose -f "$COMPOSE_FILE" -f "$POSTGRES_OVERLAY" exec -T -e PGPASSWORD="$PG_PASSWORD" db psql -U "$PG_USER" -d postgres -c "CREATE DATABASE ${PG_DB};" || true
fi

## Restore database from backup
echo "Restoring database"
if ! $DECOMPRESS "$BACKUP_FILE" | docker compose -f "$COMPOSE_FILE" -f "$POSTGRES_OVERLAY" exec -T -e PGPASSWORD="$PG_PASSWORD" db psql -U "$PG_USER" "$PG_DB" 2>&1 | tee /dev/stderr | grep -q "database is being accessed"; then
    : # Success
else
    handle_db_access_error
fi

if [[ "${RESTART_CONTAINERS}" == "true" ]]; then
  echo
  echo "Restarting Miniflux container"
  echo

  docker compose -f $COMPOSE_FILE -f $POSTGRES_OVERLAY restart miniflux
else
  echo "You many need to manually restart Miniflux, i.e.:"
  echo "  docker compose -f ${COMPOSE_FILE} -f ${POSTGRES_OVERLAY} up -d"
  echo
fi

echo "Restore complete!"
