#!/usr/bin/env bash
set -euo pipefail

echo ""
echo "CROW_AGENT_SECRET=$(openssl rand -hex 32)"
echo ""
