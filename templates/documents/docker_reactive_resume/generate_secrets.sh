#!/usr/bin/env bash
set -uo pipefail

if ! command -v openssl &>/dev/null; then
  echo "[ERROR] OpenSSL is not installed."
  exit 1
fi

SECRETS_FILE="secrets_DELETE_ME"

## Generate Postgres password (32 chars alphanumeric)
POSTGRES_PASSWORD=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)

## Generate app auth secret (64 hex chars per Reactive Resume docs)
AUTH_SECRET=$(openssl rand -hex 32)

## Write secrets to file, avoiding terminal output
cat > "$SECRETS_FILE" << EOF
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
AUTH_SECRET=${AUTH_SECRET}
EOF

chmod 600 "$SECRETS_FILE"

echo "Secrets generated in $SECRETS_FILE"
echo "!! DELETE THIS FILE after copying values to .env or into your environment !!"
