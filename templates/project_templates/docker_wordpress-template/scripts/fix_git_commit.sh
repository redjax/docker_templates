#!/bin/bash

#
# Retake ownership of directories before pushing to git
#

RESTART_CONTAINERS="y"
DC_DIR="../"
OWNER_USER="jack"
OWNER_GROUP="jack"

retake_ownership () {
    echo ""
    echo "Taking ownership of dir"
    echo ""

    cd $DC_DIR
    chown -R $OWNER_USER:$OWNER_GROUP ./*
}

main () {

    # check if script is run as root
    if [[ $EUID -ne 0 ]]; then
      echo ""
      echo "This script must be run as root."
      echo ""

      exit 1
    fi

  retake_ownership

}

main
