#!/bin/bash

#
# Run only new Wordpress sites
#

SCRIPT_DIR=${PWD}
WP_SITES_DIR="wordpress_sites"

function RUN_WP_SITE_CONTAINERS () {
    cd ..
    cd $WP_SITES_DIR

    for SITE in */; do
      echo "Executing docker-compose.yml for "$SITE
      cd $SITE
      docker-compose up -d --force-recreate
      cd ..
    done
}

function MAIN () {

    cd $SCRIPT_DIR

    RUN_WP_SITE_CONTAINERS
}

MAIN