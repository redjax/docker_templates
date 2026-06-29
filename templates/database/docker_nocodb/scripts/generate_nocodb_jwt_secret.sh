#!/usr/bin/env bash

if ! command -v openssl &>/dev/null; then
    echo "[ERROR] openssl is not installed"
    exit 1
fi

echo "NocoDB JWT secret:"
openssl rand -hex 32
