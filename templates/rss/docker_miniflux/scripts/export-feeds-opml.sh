#!/usr/bin/env bash
set -euo pipefail

#############################################################
# Export Miniflux feeds as .OPML file                       #
#                                                           #
# Requires an API key, which can be created by logging into #
# the Miniflux server and going to Settings > API Keys      #
#############################################################

if ! command -v curl >/dev/null 2>&1; then
  echo "[ERROR] curl is not installed" >&2
  exit 1
fi

function ts() {
  date '+%Y-%m-%d %H:%M:%S'
}

function err() {
  echo "$(ts) [ERROR] $*" >&2
}

function filename_ts() {
  date '+%Y-%m-%d_%H%M%S'
}

function usage() {
  cat <<EOF
Usage: ${0##*/} [OPTIONS]

Options:
  -h, --help              Show help
  -u, --url URL           Miniflux base URL
  -t, --token TOKEN       Miniflux API token
  -o, --output FILE       Output file
  -d, --dir DIR           Export directory (default: exports)
  -z, --gzip              Compress output

Environment:
  MINIFLUX_URL
  MINIFLUX_TOKEN
EOF
}

MINIFLUX_URL="${MINIFLUX_URL:-}"
MINIFLUX_TOKEN="${MINIFLUX_TOKEN:-}"
EXPORT_DIR="exports"
OUTPUT_FILE=""
COMPRESS=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -u|--url)
      MINIFLUX_URL="$2"
      shift 2
      ;;
    -t|--token|-k|--api-key)
      MINIFLUX_TOKEN="$2"
      shift 2
      ;;
    -o|--output)
      OUTPUT_FILE="$2"
      shift 2
      ;;
    -d|--dir)
      EXPORT_DIR="$2"
      shift 2
      ;;
    -z|--gzip)
      COMPRESS=1
      shift
      ;;
    *)
      echo "[ERROR] Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

[[ -n "${MINIFLUX_URL}" ]] || {
  err "Missing --url"
  exit 1
}

[[ -n "${MINIFLUX_TOKEN}" ]] || {
  echo "Missing --token"
  exit 1
}

mkdir -p "${EXPORT_DIR}"

if [[ -z "${OUTPUT_FILE}" ]]; then
  OUTPUT_FILE="${EXPORT_DIR}/$(filename_ts)_miniflux.opml"
fi

TMPFILE="$(mktemp)"

cleanup() {
  rm -f "${TMPFILE}"
}
trap cleanup EXIT

echo "[INFO] Exporting from ${MINIFLUX_URL}"

HTTP_CODE=$(
  curl \
    --silent \
    --show-error \
    --location \
    --output "${TMPFILE}" \
    --write-out '%{http_code}' \
    -H "X-Auth-Token: ${MINIFLUX_TOKEN}" \
    "${MINIFLUX_URL%/}/v1/export"
)

if [[ "${HTTP_CODE}" != "200" ]]; then
  err "Export failed (HTTP ${HTTP_CODE})"
  exit 1
fi

if ! head -n 5 "${TMPFILE}" | grep -qiE '<(opml|\?xml)'; then
  err "Downloaded file does not appear to be OPML/XML"
  exit 1
fi

mv "${TMPFILE}" "${OUTPUT_FILE}"

if [[ "${COMPRESS}" -eq 1 ]]; then
  gzip -f "${OUTPUT_FILE}"
  OUTPUT_FILE="${OUTPUT_FILE}.gz"
fi

echo "[INFO] Export completed"
echo "[INFO] Saved to ${OUTPUT_FILE}"
