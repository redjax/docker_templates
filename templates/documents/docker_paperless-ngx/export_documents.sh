#!/bin/bash

PAPERLESS_CONTAINER_NAME=webserver
docker compose exec $PAPERLESS_CONTAINER_NAME document_exporter ../export

exit $?

