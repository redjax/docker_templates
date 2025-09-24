#!/bin/bash

set -uo pipefail

if ! command -v docker &> /dev/null; then
    echo "docker is not installed"
    exit 1
fi

NEXTCLOUD_CONTAINER_NAME="nextcloud-aio-nextcloud"

echo "Starting admin password reset process."
echo "You will be prompted for the new passswword twice. You do not need to restart any containers after resetting this password."
echo ""

docker exec -it --user www-data ${NEXTCLOUD_CONTAINER_NAME} php /var/www/docker-aio/occ user:resetpassword admin
if [[ $? -ne 0 ]]; then
    echo "Failed to reset admin password."
    echo "If the error is that the nextcloud-aio-nextcloud container cannot be found, make sure you've finished the initial setup."
    exit 1
else
    echo ""
    echo "Nextcloud admin password reset."
    exit 0
fi
