#!/bin/bash

##
# Allow watchtower container to interact with docker daemon
# to remove images and pull updates/restart containers.
##

USER=${USER}

echo "Granting watchtower container permissions to interact with the Docker daemon."

sudo setfacl --modify user:${USER}:rw /var/run/docker.sock
