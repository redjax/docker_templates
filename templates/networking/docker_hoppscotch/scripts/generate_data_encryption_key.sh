#!/bin/bash

if ! command -v openssl &>/dev/null; then
    echo "OpenSSL is not installed. Please install that before continuing."
    exit 1
fi

echo "Generating data encryption key"
SECRET=$(openssl rand -hex 16)

echo ""
echo "Data encryption key:"
echo "${SECRET}"

