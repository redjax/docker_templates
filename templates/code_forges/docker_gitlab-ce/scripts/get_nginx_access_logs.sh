#!/bin/bash

docker exec -it gitlab-server tail -n 50 /var/log/gitlab/nginx/gitlab_access.log
