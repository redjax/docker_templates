#!/usr/bin/env bash
set -euo pipefail

echo "Generating Netalertx secrets"

cat <<EOF
NETALERTX_API_TOKEN=$(openssl rand -hex 32)
EOF
