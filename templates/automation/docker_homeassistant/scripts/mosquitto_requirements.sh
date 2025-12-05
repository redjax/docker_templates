#!/bin/bash

## https://pimylifeup.com/home-assistant-docker-compose/#creating-a-user-for-the-mosquitto-docker-container

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT=$(realpath -m "$THIS_DIR/../../../")

if [[ ! $(getent passwd "mosquitto" 2>&1) ]]; then

    echo "Creating mosquitto user"
    sudo useradd -u 1883 -g 1883 mosquitto

fi

if [[ ! $(getent group mosquitto /dev/null 2>&1) ]]; then
    echo "Creating mosquitto group"
    sudo groupadd -g 1883 mosquitto
fi

if [[ ! -d ./config/mosquitto ]]; then
    echo "Creating config dir"
    mkdir -pv $PROJECT_ROOT/config/mosquitto
fi

if [[ ! -f ./config/mosquitto/mosquitto.conf ]]; then
    echo "Creating config file"

    ## Create mosquitto conf file & echo config into it
    cat <<EOF >$PROJECT_ROOT/config/mosquitto/mosquitto.conf
persistence     true
persistence_location /mosquitto/data/
log_dest        file /mosquitto/log/mosquitto.log
listener        1883
listener        9001
allow_anonymous true
EOF

fi
