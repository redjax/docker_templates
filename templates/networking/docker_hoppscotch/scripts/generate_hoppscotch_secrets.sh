#!/usr/bin/env bash

set -uo pipefail

if ! command -v openssl &>/dev/null; then
    echo "[ERROR] openssl not installed"
    exit 1
fi

generate_hex()   { openssl rand -hex 32; }        # 256-bit hex
generate_b64()   { openssl rand -base64 32; }     # 256-bit base64
generate_short() { openssl rand -hex 16; }        # Shorter for salts

echo ""
echo "[ Hoppscotch Secrets ]"
echo ""
echo "- JWT_SECRET=$(generate_hex)"
echo "- SESSION_SECRET=$(generate_hex)"
echo "- DATA_ENCRYPTION_KEY=$(generate_short)"
echo ""
