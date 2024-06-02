#!/bin/bash

# THIS_DIR=${PWD}
THIS_DIR="/home/jack/docker/docker_paperless-ng"
# DOCUMENT_DIR=$THIS_DIR/media
DOCUMENTS_CONTAINER_DIR="/usr/src/paperless/data"
MEDIA_CONTAINER_DIR="/usr/src/paperless/media"
PAPERLESS_CONTAINER_NAME="paperless-server"
HOST_BACKUP_ROOT_DIR="$THIS_DIR/tmp/paperless"

# DOCUMENT_BACKUP_DIR=$THIS_DIR/backup/documents
# DOCUMENT_BACKUP_NAME=paperless_docs_backup.tar.gz
# DOCUMENT_BACKUP_PATH=$DOCUMENT_BACKUP_DIR"/"$DOCUMENT_BACKUP_NAME

function GET_TIMESTAMP () {
  date +"%Y-%m-%d_%H:%M"
}

function PREPARE_BACKUP_DIRS () {

  if [[ ! -d "$HOST_BACKUP_ROOT_DIR/data" ]]; then
    echo "Creating dir: $HOST_BACKUP_ROOT_DIR/data"
    mkdir -pv "$HOST_BACKUP_ROOT_DIR/data"
  fi

  if [[ ! -d "$HOST_BACKUP_ROOT_DIR/media" ]]; then
    echo "Creating dir: $HOST_BACKUP_ROOT_DIR/media"
    mkdir -pv "$HOST_BACKUP_ROOT_DIR/media"
  fi

}

function TRIM_BACKUPS() {

  scan_dir="$THIS_DIR/backup/paperless-data"
  day_threshold="3"

  echo "Scanning $scan_dir for backups older than $day_threshold days"
  find $scan_dir -type f -mtime +3 -delete

}

function BACKUP_PAPERLESS_DOCUMENTS2 () {

  PREPARE_BACKUP_DIRS

  timestamp="$(GET_TIMESTAMP)"
  DOCUMENT_HOST_DIR="$HOST_BACKUP_ROOT_DIR/data/$timestamp"
  DOCUMENT_BACKUP_PATH="$DOCUMENT_HOST_DIR/"
  MEDIA_HOST_DIR="$HOST_BACKUP_ROOT_DIR/media/$timestamp"
  MEDIA_BACKUP_PATH="$MEDIA_HOST_DIR"
  FINAL_BACKUP_PATH="$THIS_DIR/backup/paperless-data"

  echo "Backing up Paperless data to $DOCUMENT_BACKUP_PATH"
  docker cp $PAPERLESS_CONTAINER_NAME:$DOCUMENTS_CONTAINER_DIR $DOCUMENT_HOST_DIR

  echo "Backing up Paperless media to $MEDIA_HOST_DIR"
  docker cp $PAPERLESS_CONTAINER_NAME:$MEDIA_CONTAINER_DIR $MEDIA_HOST_DIR

  echo "Archiving $MEDIA_HOST_DIR"
  tar -czvf "$MEDIA_HOST_DIR.tar.gz" $MEDIA_HOST_DIR

  echo "Removing $MEDIA_HOST_DIR"
  rm -r $MEDIA_HOST_DIR

  echo "Archiving $DOCUMENT_HOST_DIR"
  tar -czvf "$DOCUMENT_HOST_DIR.tar.gz" $MEDIA_HOST_DIR

  echo "Removing $DOCUMENT_HOST_DIR"
  rm -r $DOCUMENT_HOST_DIR

  if ! [[ -d "$FINAL_BACKUP_PATH" ]]; then
    echo "Creating $FINAL_BACKUP_PATH"
    mkdir -pv $FINAL_BACKUP_PATH
  fi

  echo "Moving backups to $FINAL_BACKUP_PATH"

  if [[ ! -d "$FINAL_BACKUP_PATH/data" ]]; then
    echo "Creating $FINAL_BACKUP_PATH/data"

    mkdir -pv "$FINAL_BACKUP_PATH/data"
  fi

  if [[ ! -d "$FINAL_BACKUP_PATH/media" ]]; then
    echo "Creating $FINAL_BACKUP_PATH/media"

    mkdir -pv "$FINAL_BACKUP_PATH/media"
  fi

  for file in ${HOST_BACKUP_ROOT_DIR}/data/*; do
    echo "Moving file: $file to: $FINAL_BACKUP_PATH/data"

    mv $file $FINAL_BACKUP_PATH/data/
  done

  for file in ${HOST_BACKUP_ROOT_DIR}/media/*; do
    echo "Moving file: $file to: $FINAL_BACKUP_PATH/media"

    mv $file $FINAL_BACKUP_PATH/media/
  done

}

function BACKUP_PAPERLESS_DOCUMENTS () {
  
  if [[ ! -f $DOCUMENT_BACKUP_PATH ]]; then
    echo ""
    echo "Backing up Paperless documents dir."
    echo ""

    tar -zcvf $DOCUMENT_BACKUP_PATH $DOCUMENT_DIR

  elif [[ -f $DOCUMENT_BACKUP_PATH ]]; then
    echo ""
    echo "Backup exists at "$DOCUMENT_BACKUP_PATH
    echo ""
    echo "Removing and creating new backup."
    echo ""

    rm $DOCUMENT_BACKUP_PATH
    tar -zcvf $DOCUMENT_BACKUP_PATH $DOCUMENT_DIR

  else
    echo ""
    echo "Unknown error."
    echo ""
  fi

}

function RESTORE_PAPERLESS_DOCUMENTS () {

  echo ""
  echo "No restore function yet."
  echo ""

}

function main () {

  if [ $1 == "backup" ]; then
    # BACKUP_PAPERLESS_DOCUMENTS
    BACKUP_PAPERLESS_DOCUMENTS2
  elif [ $1 == "restore" ]; then
    RESTORE_PAPERLESS_DOCUMENTS
  elif [ $1 == "trim" ]; then
    TRIM_BACKUPS
  fi

}

case $1 in
 "-b" | "--backup")
   main "backup"
  ;;
  "-r" | "--restore")
    main "restore"
  ;;
  "-bt" | "--backup-trim")
    main "trim"
  ;;
  *)
    echo ""
    echo "Invalid flag: "$1
    echo ""
    echo "Valid flags: -b/--backup, -r/--restore"
    echo ""
  ;;
esac

exit