#!/bin/bash

## https://pimylifeup.com/home-assistant-docker-compose/#creating-a-user-for-the-mosquitto-docker-container

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
    mkdir -pv ./config/mosquitto
fi

if [[ ! -d ./data/mosquitto ]]; then
    echo "Creating mosquitto data dir"
    mkdir -pv ./data/mosquitto
fi

if [[ ! -d ./logs/mosquitto ]]; then
    echo "Creating mosquitto logs directory"
    mkdir -pv ./logs/mosquitto
fi

if [[ ! -f ./logs/mosquitto/mosquitto.log ]]; then
    echo "Creating empty mosquitto log file."
    touch ./logs/mosquitto/mosquitto.log
fi

if [[ ! -f ./config/mosquitto/mosquitto.conf ]]; then
    echo "Creating config file"

    ## Create mosquitto conf file & echo config into it
    cat <<EOF >./config/mosquitto/mosquitto.conf
allow_anonymous true
# password_file /mosquitto/config/pwfile
listener        1883 0.0.0.0
listener        9001 0.0.0.0
protocol websockets
persistence     true
persistence_file mosquitto.db
persistence_location /mosquitto/data/
log_type subscribe
log_type unsubscribe
log_type websockets
log_type error
log_type warning
log_type notice
log_type information
log_dest        file /mosquitto/log/mosquitto.log
EOF

    # sudo chmod 0700 ./config/mosquitto/mosquitto.conf

fi

if [[ ! -f ./data/mosquitto/mosquitto.db ]]; then
    echo "Creating empty mosquitto.db database file for container"
    touch ./data/mosquitto/mosquitto.db

    # sudo chown 1883:1883 mosquitto.db
    sudo chmod 0700 ./data/mosquitto/mosquitto.db
fi

echo "Setting owner of ./data, ./logs, ./config to 1883:1883"
declare -a chmod_dirs=(./data ./logs ./config)
for d in "${chmod_dirs[@]}"; do
    sudo chmod o+w ./logs/mosquitto/mosquitto.log
    sudo chown -R 1883:1883 "${d}"
done
