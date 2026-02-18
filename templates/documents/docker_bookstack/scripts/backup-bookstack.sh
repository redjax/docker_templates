#!/usr/bin/env bash
set -euo pipefail

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT=$(realpath -m "$THIS_DIR/..")

OUTPUT_DIR="./backups"
COMPOSE_CMD="docker compose"
DB_SERVICE="bookstack_db"
APP_SERVICE="bookstack"
DB_USER="${DB_USERNAME:-bookstack}"
DB_PASS="${DB_PASSWORD:-bookstack}"
DB_NAME="${DB_DATABASE:-bookstackapp}"
DATA_DIR="./data/bookstack"

ORIGINAL_PATH=$(pwd)

function usage() {
  echo ""
  echo "Usage: ${0} [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -h, --help                Print this help menu"
  echo "  -n, --db-name      <str>  The name of the Bookstack database"
  echo "  -u, --db-user      <str>  The database user's username"
  echo "  -p, --db-password  <str>  The database user's password"
  echo "  -o, --output-dir   <str>  The path where the backup/archive should be saved"
  echo ""
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    -o|--output-dir)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    -n|--db-name)
      DB_NAME="$2"
      shift 2
      ;;
    -u|--db-user)
      DB_USER="$2"
      shift 2
      ;;
    -p|--db-password)
      DB_PASS="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown arg: $1" >&2
      usage
      exit 1
      ;;
  esac
done

timestamp="$(date +%Y%m%d_%H%M%S)"
backup_name="bookstack_backup_${timestamp}"
tmp_dir="$(mktemp -d)"
sql_dump="${tmp_dir}/bookstack_db_${timestamp}.sql"

function cleanup() {
  rm -rf "$tmp_dir"
  cd "$ORIGINAL_PATH"
}
trap cleanup EXIT

cd "$PROJECT_ROOT"

echo "[*] Using output dir: ${OUTPUT_DIR}"
mkdir -p "${OUTPUT_DIR}"

echo "[*] Creating database dump from service: ${DB_SERVICE}"
# Dump DB from running DB container
${COMPOSE_CMD} exec -T "${DB_SERVICE}" sh -c \
  "mariadb-dump -u\"${DB_USER}\" -p\"${DB_PASS}\" \"${DB_NAME}\"" > "${sql_dump}"

echo "[*] Stopping application stack for filesystem-consistent backup"
${COMPOSE_CMD} down

echo "[*] Creating backup tarball: ${OUTPUT_DIR}/${backup_name}.tar.gz"
# Archive ONLY ./data/bookstack + SQL dump (no problematic DB files)
tar -czf "${OUTPUT_DIR}/${backup_name}.tar.gz" \
  --transform "s|^${DATA_DIR}|data/bookstack|" \
  "${DATA_DIR}" \
  -C "${tmp_dir}" "$(basename "${sql_dump}")"

echo "[*] Backup created: ${OUTPUT_DIR}/${backup_name}.tar.gz"
echo "[*] Size: $(du -h "${OUTPUT_DIR}/${backup_name}.tar.gz" | cut -f1)"

echo "[*] Cleaning up temp files"
rm -rf "${tmp_dir}"

echo "[*] Bringing stack back up"
${COMPOSE_CMD} up -d

echo "[*] Done."
