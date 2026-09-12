#!/usr/bin/env bash
set -euo pipefail

if ! command -v openssl >/dev/null 2>&1; then
  printf 'error: openssl is required but was not found in PATH\n' >&2
  exit 1
fi

postgres_password="$(openssl rand -hex 32)"

oxicloud_storage_encryption_key="$(
  openssl rand 32 | base64 | tr -d '\r\n'
)"

printf 'POSTGRES_PASSWORD=%s\n' "$postgres_password"
printf 'OXICLOUD_STORAGE_ENCRYPTION_KEY=%s\n' \
  "$oxicloud_storage_encryption_key"

