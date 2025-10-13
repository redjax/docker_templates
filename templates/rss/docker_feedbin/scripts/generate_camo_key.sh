#!/usr/bin/env bash

if ! command -v openssl &>/dev/null; then
    echo "[ERROR] openssl is not installed."
    exit 1
fi

CAMO_KEY=$(openssl rand -hex 32)

echo ""
echo "Generated FEEDBIN_CAMO_KEY: $CAMO_KEY"
echo ""
