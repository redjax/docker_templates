#!/usr/bin/env bash

if ! command -v openssl &>/dev/null; then
    echo "[ERROR] openssl is not installed"
    exit 1
fi

echo ""
echo "Generating Feedbin secret base"
echo ""

SECRET_BASE=$(openssl rand -hex 64)

echo "Feedbin secret base:"
echo $SECRET_BASE
