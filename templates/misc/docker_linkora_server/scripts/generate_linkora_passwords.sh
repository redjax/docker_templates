#!/usr/bin/env bash

echo "Generating Linkora keystore password."
KEYSTORE_PW=$(openssl rand -base64 32)
if [[ $? -ne 0 ]]; then
  echo "[ERROR] Failed generating keystore password with openssl. Using pure Bash"
  PW=$(LC_ALL=C tr -dc 'A-Za-z0-9!@#$%&*-_+=' </dev/urandom | head -c 32)
  if [[ $? -ne 0 ]]; then
    echo "[ERROR] Failed to generate Linkora keystore password."
    exit $?
  fi
fi

echo "Generating Linkora auth token"
AUTH_TOKEN=$(openssl rand -base64 32)
if [[ $? -ne 0 ]]; then
  echo "[ERROR] Failed generating auth token with openssl. Using pure Bash"
  AUTH_TOKEN=$(LC_ALL=C tr -dc 'A-Za-z0-9!@#$%&*-_+=' </dev/urandom | head -c 32)
  if [[ $? -ne 0 ]]; then
    echo "[ERROR] Failed to generate Linkora auth token."
    exit $?
  fi
fi

echo ""
echo "Linkora keystore password:"
echo "$KEYSTORE_PW"
echo ""
echo "Linkora auth token:"
echo "$AUTH_TOKEN"
