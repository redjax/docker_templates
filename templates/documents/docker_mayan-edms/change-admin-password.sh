#!/bin/bash

MAYAN_CONTAINER_NAME=mayan_app_1

docker exec -it $MAYAN_CONTAINER_NAME /opt/mayan-edms/bin/mayan-edms.py changepassword admin
