#!/usr/bin/env bash
set -euo pipefail

#######################################################
# Generate secure secrets for Miniflux Docker Compose #
#                                                     #
# Prints values to CLI for copying into .env          #
#######################################################

echo " [ Miniflux Secure Secrets Generator ]"
echo ""
echo "Copy these values into your .env file:"
echo ""

## Generate admin password (24 chars, alphanumeric + special)
ADMIN_PASSWORD=$(openssl rand -base64 32 | tr -d '/+=' | cut -c1-24)

## Generate database password (32 chars, alphanumeric only for DB compatibility)
PG_PASSWORD=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 32)

cat << EOF
# Admin settings
ADMIN_USERNAME=admin
ADMIN_PASSWORD=${ADMIN_PASSWORD}
CREATE_ADMIN=1

# PostgreSQL settings
PG_USER=miniflux
PG_PASSWORD=${PG_PASSWORD}
PG_DB=miniflux
EOF

echo ""
echo "=================================================="
echo "  IMPORTANT: Save these passwords securely!"
echo "=================================================="
echo ""
echo "After copying to .env:"
echo "  - Store passwords in a password manager"
echo "  - Never commit .env to version control"
echo "  - Run: docker compose -f compose.yml -f overlays/postgres.yml up -d"
echo ""
