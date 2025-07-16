#!/bin/bash

if ! command -v openssl &>/dev/null; then
  echo "OpenSSL is not installed. Please install that before continuing."
  exit 1
fi

echo "Generating JWT secret"
SECRET=$(openssl rand -base64 32)

echo ""
echo "JWT secret:"
echo "${SECRET}"

