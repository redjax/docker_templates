#!/usr/bin/env bash
set -uo pipefail

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="${THIS_DIR}/vikunja-secret_DELETE-ME"

echo "Generating Vikunja JWT secret, outputting to file: ${OUTPUT_FILE}"
openssl rand -hex 32 > "${OUTPUT_FILE}"
