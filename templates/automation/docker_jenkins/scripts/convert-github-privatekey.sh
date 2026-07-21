#!/usr/bin/env bash
set -euo pipefail

if ! command -v openssl >&/dev/null; then
  echo "[ERROR] OpenSSL is not installed" >&2
  exit 1
fi

KEY_FILE=
OUTPUT_FILE=

function usage() {
  cat <<EOF
Usage: ${0} [OPTIONS]

Options:
  -h, --help       Print this help menu
  -i, --input-key  Path to existing .pem key that needs converting
  -o, --output-key Path where converted key will be saved
EOF
}

function convert_key() {
  local input_key
  local output_key

  input_key="${1}"
  output_key="${2}"

  openssl pkcs8 -topk8 -inform PEM -outform PEM -in "${input_key}" -out "${output_key}" -nocrypt
}

while [[ $# -gt 0 ]]; do
  case $1 in
  -h | --help)
    usage
    exit 0
    ;;
  -i | --input-key)
    KEY_FILE="${2}"
    shift 2
    ;;
  -o | --output-key)
    OUTPUT_FILE="${2}"
    shift 2
    ;;
  *)
    echo "[ERROR] Invalid option: $1" >&2
    echo
    ;;
  esac
done

if [[ -z "${KEY_FILE}" ]]; then
  echo "[ERROR] Missing --input-key" >&2
  echo

  usage
  exit 1
fi

if [[ -z "${OUTPUT_FILE}" ]]; then
  OUTPUT_FILE="${PWD}/converted.$(basename ${KEY_FILE})"
fi

if [[ -f "${OUTPUT_FILE}" ]]; then
  while true; do
    echo "[WARNING] Output file already exists."
    read -r -n 1 -p "Continue? (y/n): " continue_choice

    case continue_choice in
    [Yy])
      break
      ;;
    [Nn])
      echo "Exiting"
      exit 0
      ;;
    *)
      echo "[ERROR] Invalid choice: ${continue_choice}. Must be 'y' or 'n'" >&2
      ;;
    esac
  done
fi

echo
echo "Converting input key: ${KEY_FILE}"
echo "Saving to path: ${OUTPUT_FILE}"
echo

if convert_key "${KEY_FILE}" "${OUTPUT_FILE}" 2>&1; then
  echo
  echo "Key converted successfully. Converted key: ${OUTPUT_FILE}"
  exit 0
else
  LAST_EXIT=$?

  echo "[ERROR] Failed to convert key" >&2
  exit "${LAST_EXIT}"
fi
