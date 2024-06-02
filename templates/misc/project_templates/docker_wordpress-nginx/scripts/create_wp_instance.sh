#!/bin/bash

# Script to create a new wordpress instance.
# There WILL BE manual setup required, such as
# editing the docker-compose.yml and .env files

EXAMPLE_WP_DIR="example_wordpress/"
WORDPRESS_SITES="wordpress_sites/"
SCRIPT_DIR=${PWD}

case "$1" in
  "")
    echo "Name of new Wordpress instance: "
    read WP_SITE_NAME_INPUT
    echo "Site name set to: "$WP_SITE_NAME_INPUT
    ;;
  *)
    echo "Site name passed as arg: "$1". Continuing"
    ;;
esac

WP_SITE_NAME=${1:-$WP_SITE_NAME_INPUT}

function CD_TO_PWD () {
    # Take terminal back to the directory
    # script was run from so cd command works
    # right
    # SCRIPT_DIR=${PWD}

    echo ""
    echo "Navigating back to "$SCRIPT_DIR
    echo ""

    cd $SCRIPT_DIR
}

function COPY_EXAMPLE_SITE () {
    # Copy an example site to live wordpress_sites
    
    # Navigate up to wordpress_nginx/ root
    cd ..

    # Copy example site to wordpress_sites
    echo "Copying example Wordpress to wordpress_sites/"$WP_SITE_NAME
    cp -R $EXAMPLE_WP_DIR wordpress_sites/$WP_SITE_NAME

    echo ""
    echo "Creating .env for wordpress_sites/"$WP_SITE_NAME
    cp $WORDPRESS_SITES/$WP_SITE_NAME/.env.example $WORDPRESS_SITES/$WP_SITE_NAME/.env

    echo ""
    echo "Site "$WP_SITE_NAME" created. Don't forget to update docker-compose.yml and .env"
    echo ""    

}

function MAIN () {

  COPY_EXAMPLE_SITE

  CD_TO_PWD
}

MAIN