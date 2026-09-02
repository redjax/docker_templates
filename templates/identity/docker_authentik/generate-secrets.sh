#!/usr/bin/env bash

set -euo pipefail

echo
printf 'PG_PASS=%s\n' "$(openssl rand -base64 36 | tr -d '\n')"
printf 'AUTHENTIK_SECRET_KEY=%s\n' "$(openssl rand -base64 60 | tr -d '\n')"
echo
