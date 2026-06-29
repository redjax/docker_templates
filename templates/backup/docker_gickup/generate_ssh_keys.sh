#!/bin/bash

PRIVATE_KEYFILE="./secrets/ssh_keys/gickup_id_rsa"
PUBLIC_KEYFILE="./secrets/ssh_keys/gickup_id_rsa.pub"
KNOWN_HOSTS_FILE="./known_hosts"

if [[ ! -f "$KNOWN_HOSTS_FILE" ]]; then
    echo "Creating known_hosts file"
    touch known_hosts
fi

if [[ ! -f "$PRIVATE_KEYFILE" ]]; then
    echo "Generating SSH key at ${PRIVATE_KEYFILE} (public key: ${PUBLIC_KEYFILE})"

    ssh-keygen -t rsa -b 4096 -f "${PRIVATE_KEYFILE}" -N ""

    if [[ ! $? -eq 0 ]]; then
        echo "[ERROR] Error generating SSH keys."
        exit $?
    fi

    echo "Showing public key"
    cat "$PUBLIC_KEYFILE"

    exit 0
else
    echo "SSH private key already exists at path '$PRIVATE_KEYFILE'."

    if [[ -f "$PUBLIC_KEYFILE" ]]; then
        echo "Showing public key"
        cat "$PUBLIC_KEYFILE"
    fi

    exit 0
fi
