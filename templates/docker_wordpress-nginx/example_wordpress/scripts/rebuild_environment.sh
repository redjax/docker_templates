#!/bin/bash

# Rebuild docker environment

cd ..

docker-compose down

rm -rf db/ src/

docker-compose up -d --force-recreate

# Run chmod script to fix permissions for
# next git commit
# ./fix_git-add.sh