#!/bin/bash

# Path to directory this script exists in
this_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Directory to store backup archive
host_backup_dir=$this_dir/backup/volume_data

# Name of volume with data to back up
data_volume_name="n8n_conf"

# Name of container with data to back up
source_container_name="n8n"

# Path in container to backup data
source_container_data_path="/home/node/.n8n"

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

if [[ ! -d $host_backup_dir ]]; then
    mkdir -pv $host_backup_dir
fi

echo "Backing up $data_volume_name"

docker run --rm \
    --volumes-from $source_container_name \
    -v $host_backup_dir:/backup \
    ubuntu \
    tar czvf /backup/n8n_conf_backup.tar /home/node/.n8n \
    && tar czvf /backup/n8n_workflows_backup.tar.gz /files
