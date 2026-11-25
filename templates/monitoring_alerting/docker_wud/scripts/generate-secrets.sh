#!/usr/bin/env bash
set -euo pipefail

echo
echo "WUD_ADMIN_PASSWORD=$(openssl rand -base64 32)"
