#!/usr/bin/env bash
set -euo pipefail

if ! command -v openssl >&/dev/null; then
  echo "[ERROR] OpenSSL is not installed" >&2
  exit 1
fi

echo "Generating NetBird secrets"
echo

## NetBird core secrets
NETBIRD_AUTH_SECRET=$(openssl rand -hex 32)
NETBIRD_STORE_ENCRYPTION_KEY=$(openssl rand -hex 32)

## Optional Postgres secret
POSTGRES_PASSWORD=$(openssl rand -hex 24)

## Output rendered secrets

cat <<EOF
NETBIRD_AUTH_SECRET=${NETBIRD_AUTH_SECRET}
NETBIRD_STORE_ENCRYPTION_KEY=${NETBIRD_STORE_ENCRYPTION_KEY}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}

NOTE: You only need to use the POSTGRES_PASSWORD if you're using the overlays/postgres.yml layer

Run the following to export the variables to your environment if you are running ./scripts/render-config.sh:

export NETBIRD_AUTH_SECRET=${NETBIRD_AUTH_SECRET}
export NETBIRD_STORE_ENCRYPTION_KEY=${NETBIRD_STORE_ENCRYPTION_KEY}
## Optional
export POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
EOF

echo
echo "[OK] Secrets generated"

