#!/bin/bash

container="traefik"
lines="50"

docker logs -tf --tail=$lines $container
