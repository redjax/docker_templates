#!/bin/bash

THIS_DIR=${PWD}
TRAEFIK_CONF_DIR=$THIS_DIR"/config"
TRAEFIK_NETWORK_NAME="spooki_proxy"
TRAEFIK_LOG_DIR=$THIS_DIR"/logs"
TRAEFIK_RULES_DIR=$THIS_DIR"/config/rules"

declare -a TOUCH_FILES=($THIS_DIR"/acme.json" $TRAEFIK_LOG_DIR"/access.log" $TRAEFIK_RULES_DIR"/middlewares.toml" $TRAEFIK_CONF_DIR"/.htpasswd")
declare -a MAKE_DIRS=($TRAEFIK_CONF_DIR $TRAEFIK_LOG_DIR $TRAEFIK_RULES_DIR)

# Setup directories
echo ""
echo "Creating directories"
echo ""
for dir in "${MAKE_DIRS[@]}"
do
  if [[ ! -d $dir ]]; then
    echo ""
    echo "Creating directory: "$dir
    echo ""
    mkdir -pv $dir
  elif [[ -d $dir ]]; then
    echo ""
    echo "Directory exists: "$dir
    echo ""
  fi
done

# Create files
echo ""
echo "Creating files"
echo ""

for file in "${TOUCH_FILES[@]}"
do
  if [[ ! -f $file ]]; then
    echo ""
    echo "Creating file: "$file
    echo ""
    touch $file
  elif [[ -f $file ]]; then
    echo ""
    echo "File exists: "$file
    echo ""
  fi
done

echo ""
echo "Setting permissions on acme.json"
echo ""
chmod 600 $THIS_DIR"/acme.json"

# Create docker network
echo ""
echo "Creating Traefik docker network: "$TRAEFIK_NETWORK_NAME" (will skip if network exists)"
echo ""
# Grep docker network before creating
docker network ls|grep $TRAEFIK_NETWORK_NAME > /dev/null || docker network create $TRAEFIK_NETWORK_NAME || true
