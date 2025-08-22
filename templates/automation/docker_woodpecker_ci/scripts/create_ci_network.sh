#!/bin/bash

NETWORK_NAME="woodpecker_net"
NET_MODE="bridge"

if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker to run this script."
    exit 1
fi

## Parse args
while [[ $# -gt 0 ]]; do
    case $1 in
        --network-name)
            NETWORK_NAME="$2"
            shift 2
            ;;
        --mode)
            NET_MODE="bridge"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "Creating network $NETWORK_NAME in $NET_MODE mode"
docker network create --driver=$NET_MODE "$NETWORK_NAME"
if [ $? -ne 0 ]; then
    echo "Failed to create network $NETWORK_NAME"
    exit 1
else
    echo "Network $NETWORK_NAME created successfully"
fi
