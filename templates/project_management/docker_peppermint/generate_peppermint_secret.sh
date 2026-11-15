#!/usr/bin/env bash
set -euo pipefail

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="${THIS_DIR}/peppermint-secret_DELETE-ME"

echo "Generating secret"
_SECRET=$(head -c 32 /dev/urandom | base64)

echo "${_SECRET}" > "${OUTPUT_FILE}"
echo "Saved secret to file '${OUTPUT_FILE}'"
