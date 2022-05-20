#!/bin/bash

declare -a INIT_DIRS=( "./db" "./import" "./pictures" "./storage" )
declare -a EXAMPLE_FILES=( ".env" )


function CREATE_DIR () {

  if [[ ! -d $1 ]]; then
    echo ""
    echo $1" does not exist. Creating."
    echo ""

    mkdir -pv $1

  elif [[ -d $1 ]]; then
    echo ""
    echo $1" exists. Skipping."
    echo ""
  else
    echo ""
    echo "Unknown error."
    echo ""
  fi

}

function COPY_EXAMPLE_FILE () {

  if [[ ! -f $1 ]]; then
    echo ""
    echo $1" does not exist. Creating."
    echo ""

    cp $1.example $1

  elif [[ -f $1 ]]; then
    echo ""
    echo $1" exists. Skipping."
    echo ""

  else
    echo ""
    echo "Unknown error."
    echo ""
  
  fi

}

for DIR in "${INIT_DIRS[@]}"
do
  CREATE_DIR $DIR
done

for FILE in "${EXAMPLE_FILES[@]}"
do
  COPY_EXAMPLE_FILE $FILE
done

echo ""
echo "Initial setup complete."
echo ""
echo "Don't forget to edit the .env file!"
echo ""

exit