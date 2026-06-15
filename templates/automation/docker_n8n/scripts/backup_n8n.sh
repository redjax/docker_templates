#!/usr/bin/env bash
set -uo pipefail

## Path to directory this script exists in
this_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(realpath -m "$this_dir/..")"
host_backup_dir="$repo_root/backup"

## Name of container with data to back up
source_container_name="n8n"

function usage() {
    echo ""
    echo "Usage: ${0} [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -o, --output-dir  Host directory where backups will be saved."
    echo "  -h, --help        Print this help menu."
    echo ""
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -o|--output-dir)
      if [[ -z "$2" ]]; then
        echo "[ERROR] --output-dir provided, but no directory path given."
        usage
        exit 1
      fi
      host_backup_dir="${2}"
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

## Default to ./backup if no -o specified
backup_base_dir="${host_backup_dir:-$this_dir/backup}"
timestamp=$(date +%Y%m%d_%H%M%S)
backup_dir="$backup_base_dir/n8n-backup-$timestamp"

mkdir -p "$backup_dir"

echo "Creating n8n backup: $backup_dir"

## Export workflows and credentials via n8n CLI to /tmp, then copy out
echo "Exporting workflows"
docker exec -u node "$source_container_name" n8n export:workflow --all --output=/tmp/workflows.json
docker cp "$source_container_name":/tmp/workflows.json "$backup_dir/"
docker exec "$source_container_name" rm /tmp/workflows.json

echo "Exporting credentials"
docker exec -u node "$source_container_name" n8n export:credentials --all --output=/tmp/credentials.json
docker cp "$source_container_name":/tmp/credentials.json "$backup_dir/"
docker exec "$source_container_name" rm /tmp/credentials.json

## Backup filesystem volumes
echo "Backing up filesystem data"
docker run --rm \
    --volumes-from "$source_container_name" \
    -v "$backup_dir":/backup \
    ubuntu \
    bash -c "tar czf /backup/n8n_conf.tar.gz -C /home/node .n8n"

docker run --rm \
    --volumes-from "$source_container_name" \
    -v "$backup_dir":/backup \
    ubuntu \
    bash -c "tar czf /backup/n8n_files.tar.gz -C /files ."

echo "Backup complete: $backup_dir" [attached_file:1]

