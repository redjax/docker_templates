#!/bin/bash

THIS_DIR=${PWD}
BACKUP_DIR=$THIS_DIR"/backup"
DATA_DIR=$THIS_DIR"/data"
PKG_MGR="apt"

declare -a PATHS=("$BACKUP_DIR" "$DATA_DIR")
declare -a DEPS=("zip" "unzip")
declare -a EX_FILES=(".env" "docker-compose.yml")


function PRETTY_TITLE () {

  echo ""
  echo "["$1"]"
  echo "-------------------------"
  echo ""

}

function CHECK_INSTALLED () {

    if ! command -v $1 &> /dev/null
    then
      PRETTY_TITLE "Install: "$1
      
      sudo $PKG_MGR install -y $1

    else
      PRETTY_TITLE "Skip: "$1

    fi

}

function CHECK_PATH () {

  if [[ ! -d $1 ]]; then
    PRETTY_TITLE "Create: $1"
    
    mkdir -pv $
    
  elif [[ -d $1 ]]; then
    PRETTY_TITLE "Skip: $1"
    
  fi

}

function COPY_EXAMPLE () {

  if [[ ! -f $1 ]]; then
    PRETTY_TITLE "Create: "$1

    cp $1.example $1
  
  elif [[ -f $1 ]]; then
    PRETTY_TITLE "Skip: "$1

  fi

}

function RESTORE_BACKUP () {

  if [[ -d $1 ]]; then
    echo ""
    echo $1" exists. Backing up."
    echo ""

    mv $1 $1.bak

    echo ""
    echo $1" backed up. Recreating empty."
    echo ""

    mkdir -pv $1

  elif [[ ! -d $1 ]]; then
    echo ""
    echo $1" does not exist."
    echo ""

  elif [[ -f $1 ]]; then
    mv $1 $1.bak

  elif [[ ! -f $1 ]]; then
    echo ""
    echo $1" does not exist."
    echo ""

  fi

  unzip 

}

function main () {

  PRETTY_TITLE "Check: Dependencies installed"
  for DEP in "${DEPS[@]}"
  do
    CHECK_INSTALLED $DEP
  done

  PRETTY_TITLE "Check: Paths exist"
  for CHECK_PATH in "${PATHS[@]}"
  do
    CHECK_PATH $CHECK_PATH
  done

  PRETTY_TITLE "Create: Config files"
  for FILE in "${EX_FILES[@]}"
  do
    FILE_PATH=$THIS_DIR"/"$FILE
    COPY_EXAMPLE $FILE_PATH
  done

  PRETTY_TITLE "Initial setup complete. \
  Fill in .env TOKEN variable \
  and run docker-compose up -d."

  exit 0

}

case "$1" in
  "-r" | "-restore")
    echo ""
    echo "Restore flag passed."
    echo ""

    RESTORE_BACKUP $DATA_DIR
  ;;
  *)
    echo "No restore flag passed, continuing."
  ;;
esac


main