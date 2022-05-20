#!/bin/bash

THIS_DIR=${PWD}
PLUGINS_IMPORT_DIR=$THIS_DIR"/plugins_import"
DEFAULT_URL_PROMPT="Don't forget to pass a URL to the script."


# Check if parameter (URL) was passed
if [ $# -eq 0 ]
then
  echo ""
  echo $DEFAULT_URL_PROMPT
  echo ""
else
  PLUGIN_URL=$1
  
  echo ""
  echo "Changing directory to "$PLUGINS_IMPORT_DIR
  echo ""

  cd $PLUGINS_IMPORT_DIR

  echo ""
  echo "Downloading: "$PLUGIN_URL
  echo ""

  wget $PLUGIN_URL
  
fi
