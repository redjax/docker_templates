#!/usr/bin/env bash

if ! command -v openssl &>/dev/null; then
    echo "[ERROR] openssl is not installed."
    exit 1
fi

DB_PASSWORD=$(openssl rand -base64 24)

echo ""
echo "Generated DB_PASSWORD: $DB_PASSWORD"
echo ""
