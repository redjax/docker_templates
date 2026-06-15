#!/usr/bin/env bash
set -uo pipefail

## Path to directory this script exists in
this_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(realpath -m "$this_dir/..")"

## Name of container to restore to
target_container_name="n8n"

function usage() {
    echo ""
    echo "Usage: ${0} [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -b, --backup-dir  Path to n8n-backup-YYYYMMDD_HHMMSS/ directory"
    echo "  -h, --help        Print this help menu."
    echo ""
}

backup_dir=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -b|--backup-dir)
      if [[ -z "$2" ]]; then
        echo "[ERROR] --backup-dir provided, but no directory path given."
        usage
        exit 1
      fi
      backup_dir="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[ERROR] Invalid argument: $1"
      usage
      exit 1
      ;;
  esac
done

[[ -z "$backup_dir" ]] && {
    echo "[ERROR] --backup-dir is required"
    usage
    exit 1
}

## Use the provided path directly (should point to n8n-backup-* dir)
backup_path="$backup_dir"

if [[ ! -d "$backup_path" ]]; then
    echo "[ERROR] Backup directory not found: $backup_path"
    exit 1
fi

## Verify required backup files exist
[[ ! -f "$backup_path/workflows.json" ]] && {
    echo "[ERROR] workflows.json not found in $backup_path"
    exit 1
}

[[ ! -f "$backup_path/credentials.json" ]] && {
    echo "[ERROR] credentials.json not found in $backup_path"
    exit 1
}

[[ ! -f "$backup_path/n8n_conf.tar.gz" ]] && {
    echo "[ERROR] n8n_conf.tar.gz not found in $backup_path"
    exit 1
}

[[ ! -f "$backup_path/n8n_files.tar.gz" ]] && {
    echo "[ERROR] n8n_files.tar.gz not found in $backup_path"
    exit 1
}

echo "Restoring from: $backup_path"

## Stop container for consistency
echo "Stopping n8n container"
docker compose -f compose.yml -f overlays/traefik.yml stop "$target_container_name"

## Restore filesystem data (clears existing first)
echo "Restoring filesystem data"
docker run --rm \
    --volumes-from "$target_container_name" \
    -v "$backup_path":/restore \
    ubuntu \
    bash -c "
        rm -rf /home/node/.n8n/* /home/node/.n8n/.[!.]* /home/node/.n8n/..?* 2>/dev/null || true &&
        tar xzf /restore/n8n_conf.tar.gz -C /home/node &&
        
        rm -rf /files/* /files/.[!.]* /files/..?* 2>/dev/null || true &&
        tar xzf /restore/n8n_files.tar.gz -C /
    "

## Import workflows and credentials
echo "Importing credentials"
docker cp "$backup_path/credentials.json" "$target_container_name":/tmp/

docker exec -u node "$target_container_name" n8n import:credentials --input=/tmp/credentials.json
docker exec "$target_container_name" rm /tmp/credentials.json

echo "Importing workflows"
docker cp "$backup_path/workflows.json" "$target_container_name":/tmp/

docker exec -u node "$target_container_name" n8n import:workflow --input=/tmp/workflows.json
docker exec "$target_container_name" rm /tmp/workflows.json

## Restart container
echo "Restarting n8n container"
docker compose -f compose.yml -f overlays/traefik.yml up -d "$target_container_name"

echo "Restore complete from $backup_path" [attached_file:1]
