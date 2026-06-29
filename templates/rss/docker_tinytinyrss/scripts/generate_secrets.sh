#!/usr/bin/env bash

set -uo pipefail

if ! command -v openssl &>/dev/null; then
    echo "[ERROR] openssl is not installed"
    exit 1
fi

## Generate 16 characters base64 DB password
DB_PASS=$(openssl rand -base64 12)

## Generate 16 characters base64 admin password
ADMIN_PASS=$(openssl rand -base64 12)

cat <<EOF
# Generated on $(date)
TTRSS_DB_PASS=$DB_PASS
TTRSS_ADMIN_PASS=$ADMIN_PASS
EOF
