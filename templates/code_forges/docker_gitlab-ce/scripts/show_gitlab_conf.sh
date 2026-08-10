#!/bin/bash

if ! command -v docker &>/dev/null; then
    echo "[ERROR] Docker is not installed."
    exit 1
fi

docker exec -it gitlab-server grep external_url /etc/gitlab/gitlab.rb
