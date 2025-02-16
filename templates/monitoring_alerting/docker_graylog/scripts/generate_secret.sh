#!/bin/bash

if ! command -v pwgen &>/dev/null; then
    echo "[WARNING] pwgen is not installed."
    echo "  Install on Debian/Ubuntu with: apt install -y pwgen"

    exit 1
fi

SECRET=$(pwgen -N 1 -s 96)

echo "Generated secret:"
echo "${SECRET}"
