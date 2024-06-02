#!/bin/bash

# THIS_DIR=${PWD}
THIS_DIR=/home/jack/docker/docker_paperless-ng
DB_CONTAINER=paperless-db
DB_USER=paperless
# DB_DUMP_NAME=paperless_db_dump.sql
# DB_DUMP_PATH=$THIS_DIR/backup/db/$DB_DUMP_NAME


function GET_TIMESTAMP () {
  date +"%Y-%m-%d_%H:%M"
}

function TRIM_BACKUPS() {

  scan_dir="$THIS_DIR/backup/db"
  day_threshold="3"

  echo "Scanning $scan_dir for backups older than $day_threshold days"
  find $scan_dir -type f -mtime +3 -delete

}

function BACKUP_PAPERLESS_DB () {

  if [[ ! -f $DB_DUMP_PATH ]]; then

    echo ""
    echo "Creating database backup."
    echo ""

    timestamp="$(GET_TIMESTAMP)"
    DB_DUMP_NAME=paperless_db_dump_$timestamp.sql
    DB_DUMP_PATH=$THIS_DIR/backup/db/$DB_DUMP_NAME

    if [[ ! -d "$THIS_DIR/backup/db" ]]; then
      echo "Creating $THIS_DIR/backup/db"
      mkdir -pv $THIS_DIR/backup/db
    fi

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
  elif [ $1 == "trim-backup" ]; then
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
    main "trim-backup"
  ;;
  *)
    echo ""
    echo "Invalid flag: "$1
    echo ""
    echo "Valid flags: -b/--backup, -r/--restore"
    echo ""
esac

exit