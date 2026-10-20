#!/bin/bash

THIS_DIR=${PWD}
PLUGINS_IMPORT_DIR=$THIS_DIR"/plugins_import"

for FILE in "$PLUGINS_IMPORT_DIR"/*; do
  echo ""
  read -r -n 1 -p "Remove: $FILE? (y/n): " CHOICE
  echo

  case $CHOICE in
  [Yy] | [Yy][Ee][Ss])
    echo ""
    echo "Removing: $FILE"

    sudo rm "$FILE"

    echo ""
    echo "Removed: $FILE"
    echo ""
    ;;
  [Nn] | [Nn][Oo])
    echo ""
    echo "Skipping $FILE"
    echo ""
    ;;
  *)
    echo "Invalid choice."
    ;;
  esac
done
