#!/bin/bash

THIS_DIR=${PWD}
PLUGINS_IMPORT_DIR=$THIS_DIR"/plugins_import"

for FILE in $PLUGINS_IMPORT_DIR/*
do
  echo ""
  echo "Remove: "$FILE" ?"
  echo "Type (Y)es/(N)o: "
  read CHOICE

  case $CHOICE in
    [Yy] | [Yy][Ee][Ss] )
      echo ""
      echo "Removing: "$FILE

      sudo rm $FILE

      echo ""
      echo "Removed: "$FILE
      echo ""
    ;;
    [Nn] | [Nn][Oo] )
      echo ""
      echo "Skipping "$FILE
      echo ""
    ;;
    *)
      echo "Invalid choice."
    ;;
  esac
done