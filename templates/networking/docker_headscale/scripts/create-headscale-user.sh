#!/bin/bash

## NOTE: Run this script AFTER the create-headscale-namespace.sh script,
#  and after Headscale is up and running

echo "[ Create Headscale User ]"
echo ""

read -r -p "New user name: " HEADSCALE_USER
echo

echo ""
echo "Creating Headscale user: ${HEADSCALE_USER}"
echo ""

if ! docker compose exec -it headscale headscale users create "${HEADSCALE_USER}" 2>&1; then
  echo "[SUCCESS] Created Headscale user: ${HEADSCALE_USER}"
else
  echo "[ERROR] Failed creating Headscale user: ${HEADSCALE_USER}"
  exit $?
fi

echo "Creating preshared keys for new user: ${HEADSCALE_USER}"
echo ""

docker compose exec -it headscale headscale preauthkeys create -e 168h -u "${HEADSCALE_USER}"
