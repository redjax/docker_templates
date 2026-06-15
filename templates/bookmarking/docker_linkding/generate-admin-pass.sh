#!/usr/bin/env bash
set -euo pipefail

## 32-character strong password
PASSWORD=$(openssl rand -base64 32 | tr -d '\n' | tr '+/' '-_')

echo "Generated admin password:"
echo "$PASSWORD"

