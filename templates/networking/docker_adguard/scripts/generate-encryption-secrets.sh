#!/usr/bin/env bash
set -euo pipefail

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT=$(realpath -m "${THIS_DIR}/..")

CERT_DIR="${ADGUARD_CERT_DIR:-${PROJECT_ROOT}/certs}"
CERT_FILE="${ADGUARD_CERT_FILE:-${CERT_DIR}/adguard.crt}"
KEY_FILE="${ADGUARD_CERT_KEY:-${CERT_DIR}/adguard.key}"

SERVER_NAME="${ADGUARD_SERVER_NAME:-${1:-}}"

if [[ -z "${SERVER_NAME}" ]]; then
  echo "[ERROR] Missing server name. Provide a hostname, i.e.: ${0} my-host.home"
  echo

  exit 1
fi

echo "Generating certs for ${SERVER_NAME}"

mkdir -p "$CERT_DIR"

if [[ -e "$CERT_FILE" ]]; then
    echo "Certificate already exists: $CERT_FILE"
else
    echo "Generating self-signed certificate: $CERT_FILE"

    openssl req \
        -x509 \
        -nodes \
        -newkey rsa:2048 \
        -days 3650 \
        -keyout "$KEY_FILE" \
        -out "$CERT_FILE" \
        -subj "/CN=${SERVER_NAME}" \
        -addext "subjectAltName=DNS:${SERVER_NAME}"

    chmod 600 "$KEY_FILE"
    chmod 644 "$CERT_FILE"

    echo "Generated:"
    echo "  Certificate: $CERT_FILE"
    echo "  Private key: $KEY_FILE"
fi

if [[ -e "$KEY_FILE" ]]; then
    echo "Private key already exists, skipping creation: $KEY_FILE"
elif [[ ! -e "$CERT_FILE" ]]; then
    echo "ERROR: certificate generation failed."
    exit 1
fi

echo
echo "Encryption certificate files:"
echo "  Certificate: $CERT_FILE"
echo "  Private key: $KEY_FILE"