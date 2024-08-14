#!/bin/bash

# Update the unifi controller container


# Pull latest image
docker compose pull unifi-controller

# Run commands to remove existing container, just in case
docker stop unifi-controller
docker rm unifi-controller

# Recreate container from new image
docker compose up -d
