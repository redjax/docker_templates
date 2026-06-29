#!/bin/bash

if ! command -v openssl &> /dev/null; then
    echo "docker not found"
    exit 1
fi

SECRET=$(openssl rand -base64 48 | tr -dc 'a-zA-Z0-9' | cut -c1-32)

echo "Woodpecker secret:"
echo "$SECRET"
