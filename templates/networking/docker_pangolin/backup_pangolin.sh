#!/bin/bash

## Make a backup of the Nginx Proxy Manager directory.

timestamp() { date +"%Y-%m-%d_%H:%M"; }

BACKUP_DEST="${HOME}/backup/pangolin"
SRC_PATH="/home/jack/git/sparse-clones/docker_pangolin/"
TAR_PATH="${BACKUP_DEST}/backup_${HOSTNAME}_pangolin_$(timestamp).tar.gz"

function make_backup() {
  echo "Backing up source path: ${SRC_PATH}"
  echo "  To destination: ${TAR_PATH}"

  sudo tar czvf "${TAR_PATH}" "${SRC_PATH}"

}

function fix_dest_dir_permissions() {
  sudo chown -R ${USER}:${USER} "${BACKUP_DEST}"
}

function main() {
  if [[ ! -d "${BACKUP_DEST}" ]]; then
    sudo mkdir -pv "${BACKUP_DEST}"
    fix_dest_dir_permissions
  fi

  make_backup

  echo "Fixing permissions on output file: ${TAR_PATH}"
  fix_dest_dir_permissions
}

main
