#!/bin/bash

if ! command -v openssl &>/dev/null; then
    echo "[ERROR] openssl is not installed"
    exit 1
fi

SECRET_OUTPUT_FILE=.authentik_secret
DB_PASS_OUTPUT_FILE=.authentik_db_pass

## Generate AUTHENTIK_SECRET_KEY
if [[ -f "$SECRET_OUTPUT_FILE" ]]; then
    echo "[ERROR] $SECRET_OUTPUT_FILE already exists. Skipping secret generation."
else
    echo "Generating Authentik secret key"
    AUTHENTIK_SECRET_KEY=$(openssl rand -base64 60)

    echo "$AUTHENTIK_SECRET_KEY" > "$SECRET_OUTPUT_FILE"
    echo "Authentik secret key generated successfully, saved to $SECRET_OUTPUT_FILE"
    echo "  Make sure to set AUTHENTIK_SECRET_KEY in env_files/authentik.env"
    echo ""
fi

## Generate secret password for AUTHENTIK_DB_PASS
if [[ -f "$DB_PASS_OUTPUT_FILE" ]]; then
    echo "[ERROR] $DB_PASS_OUTPUT_FILE already exists. Skipping secret generation."
else
    echo "Generating Authentik database password"
    AUTHENTIK_DB_PASS=$(openssl rand -base64 60 | tr -dc 'A-Za-z0-9')

    echo "$AUTHENTIK_DB_PASS" > "$DB_PASS_OUTPUT_FILE"
    echo "Authentik database password generated successfully, saved to $DB_PASS_OUTPUT_FILE"
    echo "  Make sure to set AUTHENTIK_DB_PASS in env_files/authentik.env"
    echo ""
fi
