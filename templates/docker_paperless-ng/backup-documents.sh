#!/bin/bash

# THIS_DIR=${PWD}
THIS_DIR=/home/jack/docker/paperless-ng
DOCUMENT_DIR=$THIS_DIR/media
DOCUMENT_BACKUP_DIR=$THIS_DIR/backup/documents
DOCUMENT_BACKUP_NAME=paperless_docs_backup.tar.gz
DOCUMENT_BACKUP_PATH=$DOCUMENT_BACKUP_DIR"/"$DOCUMENT_BACKUP_NAME


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

function RESTORE_Paperless_DOCUMENTS () {

  echo ""
  echo "No restore function yet."
  echo ""

}

function main () {

  if [ $1 == "backup" ]; then
    BACKUP_PAPERLESS_DOCUMENTS
  elif [ $1 == "restore" ]; then
    RESTORE_PAPERLESS_DOCUMENTS
  fi

}

case $1 in
 "-b" | "--backup")
   main "backup"
  ;;
  "-r" | "--restore")
    main "restore"
  ;;
  *)
    echo ""
    echo "Invalid flag: "$1
    echo ""
    echo "Valid flags: -b/--backup, -r/--restore"
    echo ""
esac

exit