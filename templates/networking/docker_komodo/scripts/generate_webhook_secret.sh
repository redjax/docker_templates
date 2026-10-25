#!/usr/bin/env bash
set -euo pipefail

echo "Komodo webhook secret:"
echo "$(openssl rand -hex 32)"
echo

