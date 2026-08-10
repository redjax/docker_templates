#!/usr/bin/env bash

function generate_nocodb_postgres_password() {
  if ! command -v openssl &>/dev/null; then
    echo "[ERROR] openssl is not installed"
    exit 1
  fi

  echo "Postgres password:"
  openssl rand -base64 12 | tr -d "=+/" | cut -c1-16
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  generate_nocodb_postgres_password
fi