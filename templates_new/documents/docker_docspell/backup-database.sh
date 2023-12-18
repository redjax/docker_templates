#!/bin/bash

# Make sure this matches the .env value for DOCSPELL_BACKUP_DIR
backup_dir="./backup/db"

## DATABASE VALUES

# Name of docspell db container (docspell-db by default)
db_container="docspell-db"
# Match value of .env variable DOCSPELL_DB_NAME
db_name="docspell"
# Match value of .env variable DOCSPELL_DB_USER
db_user="docspell"


function stop_docspell () {

  echo ""
  echo "Bringing stack down"
  echo ""

  docker-compose down

}

function start_docspell () {

  echo ""
  echo "Bringing stack up"
  echo ""

  docker-compose up -d

}

function start_docspell_db_only () {

  echo ""
  echo "Running only database container"
  echo ""

  docker-compose up -d -- db

}

function backup_database () {

  echo ""
  echo "Backing up database"
  echo ""

  docker exec -it $db_container pg_dump -d $db_name -U $db_user -Fc -f /opt/backup/docspell.sqlc

}

function restore_database () {

  echo ""
  echo "Restoring database"
  echo ""

  docker exec -it $db_container pg_restore -d $db_name -U $db_user -Fc /opt/backup/docspell.sqlc

}

function print_help () {

  echo ""
  echo "--------"
  echo "| HELP |"
  echo "--------"
  echo ""

  echo "-b/--backup"
  echo "   Runs a database backup"
  echo ""

  echo "-r/--restore"
  echo "   Runs a database restore"
  echo ""

  echo "-h/--help"
  echo "   Print help menu"
  echo ""

}

function main () {

  if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "" ]; then
    print_help
    exit
  fi

  # First, stop all containers
  stop_docspell

  # Bring up only the database container
  start_docspell_db_only

  case $1 in
    "-b" | "--backup")
      backup_database
    ;;
    "-r" | "--restore")
      restore_database
    ;;
    *)
      echo ""
      echo "Invalid entry: "$1
      echo ""

      print_help

      read -p "Press a key to exit..."

      exit
    ;;
  esac

  # Restart docspell
  start_docspell

}

main $1