#!/bin/bash

if [[ -f ./ssh/rundeck_id_rsa ]]; then
    echo "SSH keys already exist at ./ssh/rundeck_id_rsa{.pub}. Skipping key generation."
    exit 0
fi

if ! command -v "ssh-keygen" &> /dev/null; then
    echo "[ERROR] ssh-keygen is not installed."
    exit 1
fi

echo "Generating SSH keys for Rundeck. Outputting to ./ssh"

mkdir -p ./ssh
if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to create ./ssh directory."
    exit 1 
fi

ssh-keygen -t rsa -b 4096 -f ./ssh/rundeck_id_rsa -q -N ""
if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to generate SSH keys."
    exit 1
fi

exit 0
