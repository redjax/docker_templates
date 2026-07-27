#!/usr/bin/env bash
set -euo pipefail

echo "APP_SECRET=$(openssl rand -hex 32)"
