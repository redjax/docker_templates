#!/bin/bash

if ! command -v docker &>/dev/null; then
    echo "[ERROR] Docker is not installed."
    exit 1
fi

docker exec -it gitlab-server tail -n 50 /var/log/gitlab/nginx/gitlab_access.log
