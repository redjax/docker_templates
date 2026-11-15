#!/usr/bin/env bash
set -euo pipefail

echo "ARCANE_ENCRYPTION_KEY=$(openssl rand -hex 32)"

