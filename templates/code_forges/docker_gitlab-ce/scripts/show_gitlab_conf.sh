#!/bin/bash

docker exec -it gitlab-server grep external_url /etc/gitlab/gitlab.rb
