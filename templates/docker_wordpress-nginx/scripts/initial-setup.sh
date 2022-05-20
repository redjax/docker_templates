#!/bin/bash

#
# Run the initial setup after first cloning repository
#

SCRIPT_DIR=${PWD}
GIT_DIR=".git"
GIT_INGORE=".gitignore"
README="README.MD"

# Change if you want the working directory for this project to be different in docker/$WORDPRESS_NGINX_DIR_NAME
WORDPRESS_NGINX_DIR_NAME="wordpress_nginx"
# Change if you want to use a different name for the Docker proxy network
DOCKER_PROXY_NETWORK_NAME="proxy_net"

# Check if user passed docker directory
# in the script
case "$1" in
  "")
    echo "Full path to docker directory, i.e. /home/user/docker (no trailing slash): "
    read DOCKER_DIR_INPUT
    echo "Docker directory set to "$DOCKER_DIR_INPUT
    ;;
  *)
    echo "Docker directory passed as arg: "$1". Continuing"
    ;;
esac

DOCKER_DIR=${1:-$DOCKER_DIR_INPUT}

function CD_TO_PWD () {
  # Take terminal back to the directory
  # script was run from

  echo ""
  echo "Navigating back to "$SCRIPT_DIR
  echo ""

  cd $SCRIPT_DIR
}

function REMOVE_REPO_FILES () {
  # Remove repository files like README.md and .git

  cd $DOCKER_DIR/$WORDPRESS_NGINX_DIR_NAME

  echo "Removing .git dir"
  rm -rf .git
  echo "Removing README.md"
  rm README.md
  echo "Removing auto_git_checkout.sh"
  rm auto_git_checkout.sh
  echo "Removing initial setup script"
  cd scripts
  rm initial-setup.sh
}

function COPY_REPO_TO_HOST () {
  # Copy the repository to its own
  # directory in the host's docker/ dir
  # and remove repository files

  cd ../..

  echo ""
  echo "Copying repo to "$DOCKER_DIR"/"$WORDPRESS_NGINX_DIR_NAME
  echo ""

  cp -R docker_wordpress_nginx $DOCKER_DIR/$WORDPRESS_NGINX_DIR_NAME

}

function SETUP_PROXY () {
  cd nginx-proxy

  echo ""
  echo "Creating certs folder."
  echo ""
  echo "Go create an Origin server certificate and put it in the conf/certs folder."
  echo ""

  mkdir -pv conf/certs

  echo ""
  echo "Removing empty file from conf dir."
  echo ""

  rm conf/empty

  echo ""
  echo "Copying .env.example to .env, don't forget to fill it out!"
  echo ""

  mv .env.example .env

}

function PRINT_CF_INSTRUCTIONS () {

  clear

  echo ""
  echo "Navigate to your domain on Cloudflare."
  echo ""

  read -p "Press a key to continue..."
  echo ""

  echo "Search for instructions on creating an API DNS ZONE key with Cloudflare."
  echo ""

  read -p "Press a key to continue..."

  echo ""
  echo "Once you've created an API key, fill the PROXY_CF_TOKEN variable"
  echo "in nginx-proxy's .env file."

  echo ""
  echo "Also copy the ZONE ID key on the site's Overview page and fill the"
  echo "PROXY_CF_DOMAIN#_ZONE_ID variable."

  read -p "Press a key to continue..."

  echo ""
  echo "Navigate to site's SSL/TLS tab > Origin Server and create a certificate."
  echo "Use a wildcard domain, like '*.example.com' for the cert."
  echo "Save the PEM cert and key file to"
  echo "nginx-proxy/conf/certs/example.com.key and example.com.pem files."
  echo ""
  echo "These files do not exist, you must create them. Use your domain name"
  echo "and not 'example.com.{key,pem}"

  read -p "Press a key to continue..."

  echo ""
  echo "On the SSL/TLS Overview tab, set encryption mode to 'Full (strict)'"

  read -p "Press a key to continue..."

  echo ""
  echo "That's all!"

}

function MAIN () {

  COPY_REPO_TO_HOST

  cd $SCRIPT_DIR

  REMOVE_REPO_FILES

  # TODO: take a non-default proxy network name and update environment after copying
  echo ""
  echo "Creating docker network named "$DOCKER_PROXY_NETWORK_NAME
  echo ""
  docker network create $DOCKER_PROXY_NETWORK_NAME
  echo ""
  echo "Proxy network "$DOCKER_PROXY_NETWORK_NAME " created."

  echo ""
  cd $DOCKER_DIR/$WORDPRESS_NGINX_DIR_NAME

  SETUP_PROXY

  echo ""
  echo "Setup complete."
  echo ""
  echo "Make sure to check docker-compose.yml and .env files before running with docker-compose up -d."

  echo ""
  echo "Do you want to be guided through the Cloudflare process? Y/N: "
  read $GUIDE_CHOICE

  case $GUIDE_CHOICE in
    [Yy] | [Yy][Ee][Ss])
      PRINT_CF_INSTRUCTIONS
      ;;
    [Nn] | [Nn][Oo])
      echo ""
      echo "Got it. Guide will not be printed."
      echo ""
      ;;
    esac
}

MAIN
