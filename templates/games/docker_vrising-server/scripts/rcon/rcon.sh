#!/usr/bin/env bash

# Enable error handling
set -eo pipefail

if ! command -v mcrcon &> /dev/null; then
  echo "mcrcon is not installed, exiting.."
  exit 1
fi

V_RISING_SERVER_RCON_PORT=$1
V_RISING_SERVER_RCON_PASSWORD=$2

if [[ $V_RISING_SERVER_RCON_PORT == "" ]]; then
  V_RISING_SERVER_RCON_PORT=25575
fi

# Enable debugging
# set -x

# Ensure that RCON is enabled
# if [[ "$V_RISING_SERVER_RCON_ENABLED" != "true" ]]; then
#   echo "RCON is disabled, exiting.."
#   exit 1
# fi

if [[ "$V_RISING_SERVER_RCON_PASSWORD" == "" ]]; then
  echo "[WARNING] RCON password is empty"

  mcrcon \
    "127.0.0.1" \
    -p $V_RISING_SERVER_RCON_PORT \
    $@
else
    mcrcon \
    "127.0.0.1" \
    -p $V_RISING_SERVER_RCON_PORT \
    --password "${V_RISING_SERVER_RCON_PASSWORD}" \
    $@
fi
