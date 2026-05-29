#!/usr/bin/env bash
set -uo pipefail

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="${THIS_DIR}/vikunja-secret_DELETE-ME"
DB_PASSWORD_OUTPUT_FILE="${THIS_DIR}/vikunja-db-password_DELETE-ME"

function generate_jwt_token() {
  echo "Generating Vikunja JWT secret, outputting to file: ${OUTPUT_FILE}"
  openssl rand -hex 32 > "${OUTPUT_FILE}"
}

function generate_db_pass() {
  echo "Generating database password, outputting to file: ${DB_PASSWORD_OUTPUT_FILE}"
  openssl rand -base64 32 | tr -d '\n' | tr '/+' '_-' > "${DB_PASSWORD_OUTPUT_FILE}"
  echo >> "${DB_PASSWORD_OUTPUT_FILE}"
}

if [[ -f  "$OUTPUT_FILE" ]]; then
  while true; do
    read -r -n 1 -p "[WARNING] JWT token file already exists. Overwrite? (y/n): " _jwt_choice
    echo ""

    case $_jwt_choice in
      [Yy] | [Yy][Ee][Ss])
        generate_jwt_token
        ;;
      [Nn] | [Nn][Oo])
        echo "Skipping JWT secret regenerate"
        break
        ;;
    esac
  done
else
  generate_jwt_token
fi

echo ""

if [[ -f  "$DB_PASSWORD_OUTPUT_FILE" ]]; then
  while true; do
    read -r -n 1 -p "[WARNING] DB password file already exists. Overwrite? (y/n): " _jwt_choice
    echo ""

    case $_jwt_choice in
      [Yy] | [Yy][Ee][Ss])
        generate_jwt_token
        ;;
      [Nn] | [Nn][Oo])
        echo "Skipping DB password regenerate"
        break
        ;;
    esac
  done
else
  generate_jwt_token
fi
