#!/usr/bin/env bash

if ! command -v openssl &>/dev/null; then
    echo "[ERROR] openssl is not installed"
    exit 1
fi

echo "NocoDB admin password:"
openssl rand -base64 12 | tr -d "=+/" | cut -c1-16
