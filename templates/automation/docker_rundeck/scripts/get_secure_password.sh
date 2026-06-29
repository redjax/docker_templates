#!/bin/bash

if ! command -v "docker" &> /dev/null; then
    echo "[ERROR] Docker is not installed."
    exit 1
fi

echo "Setting up..."

docker exec -it rundeck java -jar /home/rundeck/rundeck.war --encryptpwd Jetty

if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to get secure password."
    exit 1
fi

exit 0
