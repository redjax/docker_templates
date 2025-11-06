#!/usr/bin/env bash

set -uo pipefail

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_ROOT=$(realpath -m "$THIS_DIR/..")

## Create dirs
mkdir -p $DOCKER_ROOT/jotty/{cache,config,data}

## Set permissions
sudo chown -R 1000:1000 $DOCKER_ROOT/jotty
