#!/bin/bash

## Create a directory called 'import' and mount it in the container at path:
# /usr/src/paperless/data/import

PAPERLESS_CONTAINER_NAME=webserver
docker compose exec $PAPERLESS_CONTAINER_NAME document_importer ../import

exit $?

