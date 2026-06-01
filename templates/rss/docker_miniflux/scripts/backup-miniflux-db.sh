#!/bin/bash
set -euo pipefail

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
DOCKER_ROOT=$(realpath -m "${THIS_DIR}/..")

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
BACKUP_DIR="${BACKUP_DIR:-./backups}"
PG_USER="${PG_USER:-miniflux}"
PG_DB="${PG_DB:-miniflux}"
COMPRESSION="${COMPRESSION:-gzip}"

## Usage function
function usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

Backup Miniflux PostgreSQL database to local filesystem. Assumes the miniflux database is the local overlays/postgres.yml overlay.

Options:
  --compose-file     PATH  Compose file (default: compose.yml)
  --postgres-overlay PATH  Postgres overlay file (default: overlays/postgres.yml)
  --backup-dir       PATH  Backup directory (default: ./backups)
  --pg-user          USER  PostgreSQL user (default: miniflux)
  --pg-db            NAME  PostgreSQL database (default: miniflux)
  --compression      TYPE  Compression: gzip or none (default: gzip)
  --no-compression         Shortcut for --compression none
  -h, --help               Show this help message

Examples:
  $0
  $0 --backup-dir /mnt/backups/miniflux
  $0 --no-compression --pg-user myuser --pg-db mydb
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
    --backup-dir)
      BACKUP_DIR="$2"
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
    --compression)
      COMPRESSION="$2"
      shift 2
      ;;
    --no-compression)
      COMPRESSION="none"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: Unknown option: $1" >&2
      echo "Use --help for usage information" >&2
      exit 1
      ;;
  esac
done

## Validate PG_PASSWORD is set (required for pg_dump)
if [ -z "${PG_PASSWORD:-}" ]; then
  echo "Error: PG_PASSWORD is not set" >&2
  echo "Set it in .env file or export PG_PASSWORD before running" >&2
  exit 1
fi

## Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

## Generate timestamp for backup filename
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/miniflux_${TIMESTAMP}"

if [ "$COMPRESSION" = "gzip" ]; then
  BACKUP_FILE="${BACKUP_FILE}.sql.gz"
else
  BACKUP_FILE="${BACKUP_FILE}.sql"
fi

echo "Backing up Miniflux database"
echo "Output: $BACKUP_FILE"

## Run pg_dump inside the postgres container and output to local file
if [ "$COMPRESSION" = "gzip" ]; then
  docker compose -f "$COMPOSE_FILE" -f "$POSTGRES_OVERLAY" exec -T db pg_dump -U "$PG_USER" "$PG_DB" | gzip > "$BACKUP_FILE"
else
  docker compose -f "$COMPOSE_FILE" -f "$POSTGRES_OVERLAY" exec -T db pg_dump -U "$PG_USER" "$PG_DB" > "$BACKUP_FILE"
fi

echo "Backup complete: $BACKUP_FILE"
echo "Size: $(du -h "$BACKUP_FILE" | cut -f1)"
