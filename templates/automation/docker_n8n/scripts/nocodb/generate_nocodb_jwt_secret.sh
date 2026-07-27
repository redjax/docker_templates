#!/usr/bin/env bash

function generate_nocodb_jwt_secret() {
    if ! command -v openssl &>/dev/null; then
        echo "[ERROR] openssl is not installed"
        exit 1
    fi

    echo "NocoDB JWT secret:"
    openssl rand -hex 32
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    generate_nocodb_jwt_secret
fi
