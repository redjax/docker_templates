#!/bin/bash

WP_CONTAINER="${1:-wordpress}"

echo ""
echo "Fixing permissions on wp-content to allow updating/installing themes & plugins over the Internet."
echo ""

docker exec -u root -it $WP_CONTAINER /bin/bash -c "chown -R www-data wp-content && chmod -R 755 wp-content"

echo ""
echo "Done."
echo ""