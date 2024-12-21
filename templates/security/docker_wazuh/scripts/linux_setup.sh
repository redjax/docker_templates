#!/bin/bash

## Set current working directory in a var for 'cd' later
CWD=$(pwd)

## Check the latest Wazuh version at:
#    https://github.com/wazuh/wazuh-docker/releases/latest
WAZUH_VERSION="4.12.0"

## Wazuh install type (single-node, multi-node)
WAZUH_INSTALL_TYPE="single-node"

## 0=disabled, 1=enabled
USING_REVERSE_PROXY=1
## Ensure USING_REVERSE_PROXY is a numeric value (and strip spaces)
USING_REVERSE_PROXY=$(echo "$USING_REVERSE_PROXY" | tr -d '[:space:]')

PROXY_ADDRESS=${WAZUH_PROXY_ADDRESS:-""}

## Ask kernel to give the wazuh process at least 262,144 memory-mapped areas.
#  The Wazuh indexer creates many of these memory maps.
MAX_MAP_COUNT=262144

## Input string to be added or replaced
NEW_LINE="vm.max_map_count=${MAX_MAP_COUNT}"

## File to modify
SYSCTL_FILE="/etc/sysctl.conf"

## Check if Docker Compose is installed
if ! command -v docker compose --help > /dev/null 2>&1; then
    echo "docker compose is not installed"
    exit 1
fi

## Check if git is installed
if ! command -v git > /dev/null 2>&1; then
    echo "git is not installed"
    exit 1
fi

function set_systctl_max_map_count() {
    echo "Setting max memory map count to: ${MAX_MAP_COUNT}"
    
    if [[ ! -f "/etc/sysctl.conf" ]]; then
        echo "[ERROR] This machine does not have a /etc/sysctl.conf file"
        exit 1
    fi

    ## Check if the line exists
    if grep -q "^vm.max_map_count=" "$SYSCTL_FILE"; then
        ## Replace the line
        sudo sed -i "s|^vm.max_map_count=.*|$NEW_LINE|" "$SYSCTL_FILE"

        if [[ $? -ne 0 ]]; then
            echo "Failed to update the vm.max_map_count value in $SYSCTL_FILE"
            exit 1
        else
            echo "Updated the vm.max_map_count value in $SYSCTL_FILE"
        fi

    else
        ## Append the line
        echo "$NEW_LINE" | sudo tee -a "$SYSCTL_FILE" > /dev/null

        if [[ $? -ne 0 ]]; then
            echo "Failed to add the vm.max_map_count value to $SYSCTL_FILE"
            exit 1
        else
            echo "Added the vm.max_map_count value to $SYSCTL_FILE"
        fi

    fi
}

function clone_wazuh_repo() {
    if [[ -d "./wazuh-docker" ]]; then
        echo "Directory ./wazuh-docker already exists, skipping clone."
        return
    fi

    echo "Cloning Wazuh repository"

    git clone https://github.com/wazuh/wazuh-docker.git # -b v4.9.2

    if [[ $? -ne 0 ]]; then
        echo "Failed to clone Wazuh repository"
        exit 1
    fi

    cd wazuh-docker

    echo "Checking out branch ${WAZUH_VERSION}"
    git checkout $WAZUH_VERSION

    if [[ $? -ne 0 ]]; then
        echo "Failed to checkout branch ${WAZUH_VERSION}"
        exit 1
    else
        cd $CWD
    fi
}

function configure_reverse_proxy() {
    if [[ ! -d "./wazuh-docker/${WAZUH_INSTALL_TYPE}" ]]; then
        echo "Directory ./wazuh-docker/${WAZUH_INSTALL_TYPE} does not exist"
        exit 1
    fi

    cd ./wazuh-docker/${WAZUH_INSTALL_TYPE}
    if [[ $? -ne 0 ]]; then
        echo "Failed to change directory to ./wazuh-docker/${WAZUH_INSTALL_TYPE}"
        exit 1
    fi

    ## Check if the content already exists in the file with flexible indentation
    if grep -Pq "^\s*environment:" ./generate-indexer-certs.yml && grep -Pq "^\s*- HTTP_PROXY=" ./generate-indexer-certs.yml; then
        if [[ -z "${PROXY_ADDRESS}" ]]; then
            echo ""
            echo "PROXY_ADDRESS is empty or null."
            read -p "Please enter your Wazuh reverse proxy address/domain name: " PROXY_ADDRESS
            echo ""
        else
            echo "Using PROXY_ADDRESS: ${PROXY_ADDRESS}"
        fi

        # Check if the current value of HTTP_PROXY in the file is different from PROXY_ADDRESS
        current_proxy=$(grep -P "^\s*- HTTP_PROXY=" ./generate-indexer-certs.yml | sed 's/^\s*- HTTP_PROXY=//')
        
        if [[ "${current_proxy}" != "${PROXY_ADDRESS}" ]]; then
            echo "Updating HTTP_PROXY from '${current_proxy}' to '${PROXY_ADDRESS}'"
            # Use a different delimiter for sed to avoid conflicts with slashes in PROXY_ADDRESS
            sed -i "s|^\s*- HTTP_PROXY=.*$|        - HTTP_PROXY=${PROXY_ADDRESS}|" ./generate-indexer-certs.yml
            echo "Updated environment variable in ./generate-indexer-certs.yml"
        else
            echo "HTTP_PROXY is already set to the correct value: ${PROXY_ADDRESS}"
        fi
    else
        echo "Reverse proxy env variable not detected in ./generate-indexer-certs.yml. Appending line to container file."

        cat >> ./generate-indexer-certs.yml << EOF
    environment:
      - HTTP_PROXY=${PROXY_ADDRESS}
EOF
    fi

    ## Return to CWD
    cd $CWD
}

function generate_wazuh_certs() {
    cd ./wazuh-docker/${WAZUH_INSTALL_TYPE}

    echo "[DEBUG] PWD: $(pwd)"

    echo "Generating Wazuh indexer SSL certificates."
    docker compose -f generate-indexer-certs.yml run --rm generator

    if [[ ! $? -eq 0 ]]; then
        echo "Failed to generate Wazuh indexer SSL certificates."
        exit 1
    fi

    cd $CWD
}

function main() {
    if [[ "$USING_REVERSE_PROXY" =~ ^[0-9]+$ ]] && ((USING_REVERSE_PROXY == 1)); then
        echo "USING_REVERSE_PROXY=1, reverse proxy support will be enabled."

        ## Check PROXY_ADDRESS
        if [[ -z "${PROXY_ADDRESS}" ]]; then
            echo ""
            echo "PROXY_ADDRESS is empty or null."
            read -p "Please enter your Wazuh reverse proxy address/domain name: " PROXY_ADDRESS
            echo ""
        fi

        echo "Using PROXY_ADDRESS: ${PROXY_ADDRESS}"
    fi

    set_systctl_max_map_count
    
    clone_wazuh_repo

    if [[ "${USING_REVERSE_PROXY}" -eq 1 ]]; then
        configure_reverse_proxy

        if [[ $? -ne 0 ]]; then
            echo "Failed to configure reverse proxy"
            exit 1
        fi
    fi

    generate_wazuh_certs
}

main

