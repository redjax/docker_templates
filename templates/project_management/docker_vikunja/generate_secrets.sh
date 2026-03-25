#!/usr/bin/env bash
set -uo pipefail

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="${THIS_DIR}/vikunja-secret_DELETE-ME"
DB_PASSWORD_OUTPUT_FILE="${THIS_DIR}/vikunja-db-password_DELETE-ME"

echo "Generating Vikunja JWT secret, outputting to file: ${OUTPUT_FILE}"
openssl rand -hex 32 > "${OUTPUT_FILE}"

echo
echo "Generating database password, outputting to file: ${DB_PASSWORD_OUTPUT_FILE}"
openssl rand -base64 32 | tr -d '\n' | tr '/+' '_-' > "${DB_PASSWORD_OUTPUT_FILE}"
echo >> "${DB_PASSWORD_OUTPUT_FILE}"
