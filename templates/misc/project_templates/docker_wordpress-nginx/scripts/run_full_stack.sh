#!/bin/bash

#
# Run the full stack
#

SCRIPT_DIR=${PWD}
NGINX_DIR="nginx-proxy"
WP_SITES_DIR="wordpress_sites"

function RUN_NGINX_CONTAINER () {
    echo ""
    echo "Running nginx container"
    echo ""

    cd ..
    cd $NGINX_DIR
    docker-compose up -d --force-recreate
}

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

    RUN_NGINX_CONTAINER

    cd $SCRIPT_DIR

    RUN_WP_SITE_CONTAINERS
}

MAIN