#!/usr/bin/env bash
set -euo pipefail

echo "MINDWTR_CLOUD_AUTH_TOKENS=$(openssl rand -hex 32)"
