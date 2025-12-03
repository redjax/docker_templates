#!/usr/bin/env bash

set -uo pipefail

## Path to directory this script exists in
this_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(realpath -m "$this_dir/../..")"

echo ""
echo "[ NocoDB First Run Setup ]"
echo ""

while true; do
  read -n 1 -r -p "Are you using a host volume mount, i.e. ./nocodb/data:/usr/app/data ? (y/n) " yn
  echo ""

  case $yn in
      [Yy]*)
        echo ""
        echo "Creating ${project_root}/nocodb/data"
        mkdir -p "${project_root}/nocodb/data"
        echo "Creating ${project_root}/nocodb/postgres_data"
        mkdir -p "${project_root}/nocodb/postgres_data"
        echo ""
        break
        ;;
      [Nn]*)
        echo "Skipping host volume setup"
        break
        ;;
      *)
        echo "[ERROR] Invalid choice: $yn. Please use 'y' or 'n'"
        ;;
  esac
done

NOCODB_ADMIN_PW_SCRIPT="${this_dir}/generate_nocodb_admin_password.sh"
NOCODB_JWT_SECRET_SCRIPT="${this_dir}/generate_nocodb_jwt_secret.sh"
NOCODB_POSTGRES_PASSWORD_SCRIPT="${this_dir}/generate_postgres_password.sh"
COMPOSE_DOTENV_FILE="${project_root}/.env"

## Generate nocodb admin password
if [[ ! -f "${NOCODB_ADMIN_PW_SCRIPT}" ]]; then
  echo "[ERROR] Could not find nocodb admin password script at path: ${NOCODB_ADMIN_PW_SCRIPT}"
  echo "  You can manually generate a password with:"
  echo "    openssl rand -base64 12 | tr -d "=+/" | cut -c1-16"
else
  echo ""
  echo "[ Generate NocoDB admin password ]"
  echo ""

  . "$NOCODB_ADMIN_PW_SCRIPT"
  generate_nocodb_admin_password

  echo "Edit the .env file at '${COMPOSE_DOTENV_FILE}'"
  echo "Paste the value above into 'NOCODB_ADMIN_PASSWORD'"
  echo ""
fi

## Generate nocodb JWT secret
if [[ ! -f "${NOCODB_JWT_SECRET_SCRIPT}" ]]; then
  echo "[ERROR] Could not find nocodb JWT secret script at path: ${NOCODB_JWT_SECRET_SCRIPT}"
  echo "  You can manually generate a secret with:"
  echo "    openssl rand -hex 32"
  echo ""
else
  echo ""
  echo "[ Generate nocodb JWT token ]"
  echo ""

  . "$NOCODB_JWT_SECRET_SCRIPT"
  generate_nocodb_jwt_secret
  
  echo ""
  echo "Edit the .env file at '${COMPOSE_DOTENV_FILE}'"
  echo "Paste the value above into 'NOCODB_JWT_SECRET'"
  echo ""
fi

## Generate nocodb postgres password
if [[ ! -f "${NOCODB_POSTGRES_PASSWORD_SCRIPT}" ]]; then
  echo "[ERROR] Could not find nocodb postgres password script at path: ${NOCODB_POSTGRES_PASSWORD_SCRIPT}"
  echo "  You can manually generate a secret with:"
  echo "    openssl rand -base64 12 | tr -d "=+/" | cut -c1-16"
  echo ""
else
  echo ""
  echo "[ Generate nocodb Postgres password ]"
  echo ""

  . "$NOCODB_POSTGRES_PASSWORD_SCRIPT"
  generate_nocodb_postgres_password
  
  echo ""
  echo "Edit the .env file at '${COMPOSE_DOTENV_FILE}'"
  echo "Paste the value above into 'NOCODB_POSTGRES_PASSWORD'"
  echo ""
fi
