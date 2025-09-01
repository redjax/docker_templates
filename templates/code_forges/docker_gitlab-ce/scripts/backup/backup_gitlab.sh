#!/bin/bash

#################
# Gitlab Backup #
#################

## Description:
#    This script backs up the entire Gitlab docker directory.
#    Use ./backup_gitlab.sh -h for help/usage.
#
## Schedule with cron
#    You should probably use sudo crontab -e to edit the root
#    crontab, because the container directories are owned by root.
#
#    Use this schedule:
#      0 */6 * * * /bin/bash -c "/path/to/docker_gitlab-ce/scripts/backup/backup_gitlab.sh --src-dir /path/to/gitlab/container --dest-dir /path/to/backup &> /var/log/docker_gitlab/backup.log"
#
#    You should also add a logrotate configuration to keep the file from getting too large.
#    Create a file at /etc/logrotate.d/docker_gitlab_backup with the following contents:
#      /var/log/docker_gitlab/backup.log {
#          daily
#          rotate 14
#          compress
#          delaycompress
#          missingok
#          notifempty
#          create 0640 root adm
#      }
##

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GITLAB_DOCKER_DIR="$(dirname "$THIS_DIR")"

SRC_DIR="$GITLAB_DOCKER_DIR"
DEST_DIR="/opt/gitlab/backup"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -s|--src-dir)
            echo "-s/--src-dir detected. Value: $2"
            if [[ -z $2 ]]; then
                echo "[ERROR] --src-dir flag provided but no source dir given"
                exit 1
            fi

            SRC_DIR="$2"
            shift 2
            ;;
        -d|--dest-dir)
            if [[ -z $2 ]]; then
                echo "[ERROR] --dest-dir flag provided but no destination dir given"
                exit 1
            fi

            DEST_DIR="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: ./backup_gitlab.sh [-s/--src-dir] </path/to/src> [-d/--dest-dir] </path/to/dest>"
            exit 0
            ;;
        *)
            echo "[ERROR] Invalid flag: $1"
            exit 1
            ;;
    esac
done

if ! command -v rsync &>/dev/null; then
    echo "[ERROR] rsync is not installed."
    exit 1
fi

echo "[DEBUG] Source dir: $SRC_DIR | Destination dir: $DEST_DIR"

## Ensure paths exist

if [[ ! -d "$SRC_DIR" ]]; then
    echo "[ERROR] Source directory does not exist: $SRC_DIR"
    exit 1
fi

if [[ ! -d "$DEST_DIR" ]]; then
    echo "[WARNING] Could not find backup destination path: $DEST_DIR"
    echo "          Attempting to create it now"

    mkdir -p "$DEST_DIR"
    if [[ $? -ne 0 ]]; then
        echo "[ERROR] Failed to create backup destination path: $DEST_DIR"
        exit 1
    fi
fi

echo "Backing up source path '$SRC_DIR' to destination path '$DEST_DIR'"
rsync -azv --progress "$SRC_DIR/." "$DEST_DIR/."
if [[ $? -ne 0 ]]; then
  echo "[ERROR] Failed to backup source path '$SRC_DIR' to destination '$DEST_DIR'"
  exit $?
else
  echo "Completed backup of path '$SRC_DIR' to destination '$DEST_DIR'"
  exit 0
fi
