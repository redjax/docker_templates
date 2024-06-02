#!/bin/bash

THIS_DIR=${PWD}
BACKUP_DIR=$THIS_DIR"/backup"
PKG_MGR="apt"


function GET_TIMESTAMP () {
  date +"%Y-%m-%d_%H:%M"
}

function CREATE_BACKUP () {
  # Variable to store timestamp
  TS="$(GET_TIMESTAMP)"
  BACKUP_NAME="red-discordbot_backup_"$TS
  # BACKUP_PATH=$BACKUP_DIR"/"$BACKUP_NAME
  BACKUP_PATH=$BACKUP_DIR"/red-discordbot_backup"

  if [[ -f $BACKUP_PATH".zip" ]];
  then
    echo ""
    echo $BACKUP_PATH".zip exists. Deleting."
    echo ""

    rm $BACKUP_PATH".zip"

  elif [[ ! -f $BACKUP_PATH".zip" ]];
  then
    echo ""
    echo $BACKUP_PATH".zip does not exist. Creating."
    echo ""
  fi
  
  echo ""
  echo "Creating backup: "$BACKUP_PATH".zip"
  echo ""

  zip $BACKUP_PATH -r ./data ./docker-compose.yml invite-link ./.env

}

function CHECK_INSTALLED () {

    if ! command -v $1 &> /dev/null
    then
      echo ""
      echo $1" could not be found. Installing."
      echo ""
      sudo $PKG_MGR install -y $1
    else:
      echo ""
      echo $1" is installed. Skipping."
      echo ""
    fi

}

function CHECK_PATH () {

  if [[ ! -d $1 ]]; then
    mkdir -pv $1
  fi

}

function RESTORE_BACKUP () {

  CHECK_DIRS=(./data ./docker-compose.yml invite-link ./.env)

  for CHECK in "${CHECK_DIRS[@]}"
  do
    if [[ -d $CHECK ]]; then
      echo ""
      echo $CHECK" exists. Backing up."
      echo ""

      mv $CHECK $CHECK.bak

      echo ""
      echo $CHECK" backed up."
      echo ""

    elif [[ ! -d $1 ]]; then
      echo ""
      echo $CHECK" does not exist."
      echo ""

    elif [[ -f $CHECK ]]; then

      mv $CHECK $CHECK.bak

    elif [[ ! -f $CHECK ]]; then
      echo ""
      echo $CHECK" does not exist."
      echo ""

    fi
  done

  unzip 

}

function main () {
  declare -a DEPS=("zip" "unzip")

  for DEP in "${DEPS[@]}"
  do
    CHECK_INSTALLED $DEP
  done

  CHECK_PATH $BACKUP_DIR

  CREATE_BACKUP

}

case "$1" in
  "-r" | "-restore")
    echo ""
    echo "Restore flag passed."
    echo ""

    RESTORE_BACKUP
  ;;
  *)
    echo "No restore flag passed, continuing."
  ;;
esac

main