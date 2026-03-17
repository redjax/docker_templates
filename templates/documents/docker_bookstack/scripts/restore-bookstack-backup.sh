#!/usr/bin/env bash
set -euo pipefail

COMPOSE_CMD="docker compose"
DB_SERVICE="bookstack_db"
DB_USER="${DB_USERNAME:-bookstack}"
DB_PASS="${DB_PASSWORD:-bookstack}"
DB_NAME="${DB_DATABASE:-bookstackapp}"
DB_ROOT_PASSWORD="${DB_ROOT_PASSWORD:-bookstackAdmin!}"
BACKUP_FILE=""

## Safe .env parser, load .env values safely (including secret strings that normally break bash)
function load_dotenv() {
  local env_file="${1:-.env}"
  if [[ ! -f "${env_file}" ]]; then
    return 0
  fi

  while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip comments, empty lines
    [[ "${line}" =~ ^[[:space:]]*# || -z "${line// }" ]] && continue

    # Export line directly (handles quotes, base64, special chars)
    export "${line%%#*}"  # Strip inline comments
  done < "${env_file}"
}

if ! load_dotenv >&2; then
  echo "[WARNING] Could not source config from .env file" >&2
fi

function usage() {
  echo ""
  echo "Usage: ${0} -f <backup.tar.gz> [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -h, --help                Print this help menu"
  echo "  -f, --backup-file <file>  REQUIRED: Path to backup .tar.gz file"
  echo "  -n, --db-name      <str>  The name of the Bookstack database"
  echo "  -u, --db-user      <str>  The database user's username"
  echo "  -p, --db-password  <str>  The database user's password"
  echo ""
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    -f|--backup-file)
      BACKUP_FILE="$2"
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

# Validate backup file
if [[ -z "${BACKUP_FILE}" ]] || [[ ! -f "${BACKUP_FILE}" ]]; then
  echo "ERROR: Backup file required and must exist: -f <backup.tar.gz>" >&2
  usage
  exit 1
fi

echo "[*] Restoring from: ${BACKUP_FILE}"
echo "[*] Database: ${DB_NAME}"
echo "[*] Root password: ${DB_ROOT_PASSWORD:0:8}..."  # Show first 8 chars for verification
echo "[*] Proceed? (y/N): "
read -r response
if [[ ! "${response}" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

tmp_dir="$(mktemp -d)"
trap "rm -rf '${tmp_dir}'" EXIT

echo "[*] Extracting backup to temp directory..."
tar -xzf "${BACKUP_FILE}" -C "${tmp_dir}"

# Find SQL dump and bookstack data
SQL_FILE=$(find "${tmp_dir}" -name "bookstack_db_*.sql" | head -1)
BOOKSTACK_DATA=$(find "${tmp_dir}" -type d -path "*/data/bookstack" | head -1)

if [[ -z "${SQL_FILE}" ]]; then
  echo "ERROR: No SQL dump found in backup" >&2
  exit 1
fi

if [[ -z "${BOOKSTACK_DATA}" ]]; then
  echo "ERROR: No bookstack data directory found in backup" >&2
  exit 1
fi

echo "[*] Found SQL dump: $(basename "${SQL_FILE}")"
echo "[*] Found BookStack data: ${BOOKSTACK_DATA}"

echo "[*] Stopping stack (if running)..."
${COMPOSE_CMD} down || true

echo "[*] Starting database only for restore..."
${COMPOSE_CMD} up "${DB_SERVICE}" -d
sleep 10

echo "[*] Copying BookStack data to ./data/bookstack..."
sudo rm -rf ./data/bookstack
sudo mkdir -p ./data/bookstack
sudo chown 1000:995 ./data/bookstack
sudo tar -xzf "${BACKUP_FILE}" -C ./data/ --strip-components=1 "data/bookstack"
sudo chown -R 1000:995 ./data/bookstack

echo "[*] Dropping and recreating database..."
${COMPOSE_CMD} exec -T "${DB_SERVICE}" mariadb -u root -p"${DB_ROOT_PASSWORD}" <<- EOF
DROP DATABASE IF EXISTS \`${DB_NAME}\`;
CREATE DATABASE \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

echo "[*] Importing database dump..."
cat "${SQL_FILE}" | ${COMPOSE_CMD} exec -T "${DB_SERVICE}" mariadb -u "${DB_USER}" -p"${DB_PASS}" "${DB_NAME}"

echo "[*] Starting full stack..."
${COMPOSE_CMD} up -d

echo "[*] Waiting for BookStack..."
sleep 15

echo "[*] Restore complete!"
echo "[*] Check logs: ${COMPOSE_CMD} logs bookstack"

