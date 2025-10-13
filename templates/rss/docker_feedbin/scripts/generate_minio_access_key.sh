#!/usr/bin/env bash

set -uo pipefail

if ! command -v openssl &>/dev/null; then
    echo "[ERROR] openssl is not installed."
    exit 1
fi

echo ""
echo "Generating Minio access & secret keys"
echo ""

ACCESS_KEY=$(openssl rand -base64 20)
SECRET_KEY=$(openssl rand -base64 40)

echo "Access key: ${ACCESS_KEY}"
echo "Secret key: ${SECRET_KEY}"
echo ""
