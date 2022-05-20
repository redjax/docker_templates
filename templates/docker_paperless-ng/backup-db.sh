#!/bin/bash

# THIS_DIR=${PWD}
THIS_DIR=/home/jack/docker/paperless-ng
DB_CONTAINER=paperless_db_1
DB_USER=paperless
DB_DUMP_NAME=paperless_db_dump.sql
DB_DUMP_PATH=$THIS_DIR/backup/db/$DB_DUMP_NAME


function BACKUP_PAPERLESS_DB () {

  if [[ ! -f $DB_DUMP_PATH ]]; then

    echo ""
    echo "Creating database backup."
    echo ""

    docker exec -t $DB_CONTAINER pg_dumpall -c -U $DB_USER > $DB_DUMP_PATH

    echo ""
    echo "Backup saved to: "$DB_DUMP_PATH
    echo ""

  elif [[ -f $DB_DUMP_PATH ]]; then
    echo ""
    echo $DB_DUMP_PATH" exists."
    echo ""
    echo "Removing and creating new backup."
    echo ""

    rm $DB_DUMP_PATH
    docker exec -t $DB_CONTAINER pg_dumpall -c -U $DB_USER > $DB_DUMP_PATH

  else

    echo ""
    echo "Unknown error."
    echo ""
  fi

}

function RESTORE_MAYAN_DB () {

  echo ""
  echo "No restore function yet."
  echo ""

  # cat dumpfile.sql | docker exec -i $DB_CONTAINER psql -U $DB_USER
  
}

function main () {

  if [ $1 == "backup" ]; then
    BACKUP_PAPERLESS_DB
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