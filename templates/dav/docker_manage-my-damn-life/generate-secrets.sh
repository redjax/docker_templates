#!/usr/bin/env bash

set -euo pipefail

echo
echo "Generating secrets for Manage My Damn Life container."
echo "Paste the values below into your .env file."
echo

echo "MYSQL_PASSWORD=$(openssl rand -hex 32)"
echo "MYSQL_ROOT_PASSWORD=$(openssl rand -hex 32)"
