#!/bin/bash

THIS_DIR=${PWD}
DOCUMENT_DIR=$THIS_DIR/media
DOCUMENT_BACKUP_DIR=$THIS_DIR/backup/documents
DOCUMENT_BACKUP_NAME=mayan_docs_backup_`date +%Y-%m-%d"_"%H_%M`.tar.gz
DOCUMENT_BACKUP_PATH=$DOCUMENT_BACKUP_DIR"/"$DOCUMENT_BACKUP_NAME


function BACKUP_MAYAN_DOCUMENTS () {
  
  if [[ ! -f $DOCUMENT_BACKUP_PATH ]]; then
    echo ""
    echo "Backing up Mayan documents dir."
    echo ""

    tar -zcvf $DOCUMENT_BACKUP_PATH $DOCUMENT_DIR

  elif [[ -f $DOCUMENT_BACKUP_PATH ]]; then
    echo ""
    echo "Backup exists at "$DOCUMENT_BACKUP_PATH
    echo ""

  else
    echo ""
    echo "Unknown error."
    echo ""
  fi

}

function RESTORE_MAYAN_DOCUMENTS () {

  echo ""
  echo "No restore function yet."
  echo ""

}

function main () {

  if [ $1 == "backup" ]; then
    BACKUP_MAYAN_DOCUMENTS
  elif [ $1 == "restore" ]; then
    RESTORE_MAYAN_DOCUMENTS
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