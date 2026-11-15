#!/usr/bin/env bash
set -euo pipefail

url_safe_secret() {
  openssl rand -base64 48 | tr -d '\n' | tr '+/' '-_' | tr -d '='
}

hex_key_32_bytes() {
  openssl rand -hex 32
}

printf '%s\n\n' 'Generating Open Archiver secrets'

printf '%s\n' '[+] PostgreSQL / Valkey'
printf 'POSTGRES_PASSWORD=%s\n' "$(url_safe_secret)"
printf 'REDIS_PASSWORD=%s\n\n' "$(url_safe_secret)"

printf '%s\n' '[+] Meilisearch'
printf 'MEILI_MASTER_KEY=%s\n\n' "$(url_safe_secret)"

printf '%s\n' '[+] Open Archiver application'
printf 'JWT_SECRET=%s\n' "$(url_safe_secret)"
printf 'ENCRYPTION_KEY=%s\n' "$(hex_key_32_bytes)"
printf 'STORAGE_ENCRYPTION_KEY=%s\n' "$(hex_key_32_bytes)"
