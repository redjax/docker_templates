#!/usr/bin/env bash

echo "Generating Linkora keystore password."
if ! KEYSTORE_PW=$(openssl rand -base64 32) 2>&1; then
  echo "[ERROR] Failed generating keystore password with openssl. Using pure Bash"
  if ! LC_ALL=C tr -dc 'A-Za-z0-9!@#$%&*-_+=' </dev/urandom | head -c 32 2>&1; then
    echo "[ERROR] Failed to generate Linkora keystore password."
    exit 1
  fi
fi

echo "Generating Linkora auth token"
if ! AUTH_TOKEN=$(openssl rand -base64 32) 2>&1; then
  echo "[ERROR] Failed generating auth token with openssl. Using pure Bash"

  if ! AUTH_TOKEN=$(LC_ALL=C tr -dc 'A-Za-z0-9!@#$%&*-_+=' </dev/urandom | head -c 32) 2>&1; then
    echo "[ERROR] Failed to generate Linkora auth token."
    exit 1
  fi
fi

echo ""
echo "Linkora keystore password:"
echo "$KEYSTORE_PW"
echo ""
echo "Linkora auth token:"
echo "$AUTH_TOKEN"
