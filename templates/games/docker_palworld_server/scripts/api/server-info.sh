#!/usr/bin/env bash
set -euo pipefail

if ! command -v curl >&/dev/null; then
  echo "[ERROR] curl is not installed" >&2
  exit 1
fi

SERVER_URL="${PALWORLD_SERVER_URL:-}"
SERVER_PORT="${PALWORLD_SERVER_PORT:-8211}"
PALWORLD_ADMIN_USER="${PALWORLD_ADMIN_USER:-admin}"
PALWORLD_ADMIN_PASSWORD="${PALWORLD_ADMIN_PASSWORD:-adminPasswordHere}"

function usage() {
  cat <<EOF
Usage:
  ${0} [OPTIONS]

Options:
  -h, --help               Print this help menu
  --url          <string>  The Palworld server URL, i.e. http://192.168.1.xxx. The port is passed separately.
  -p, --port     <int>     The Palworld server API port. Default: 8211
  -u, --username <string>  The admin username. Default: admin
  -P, --password <string>  The admin password. Default: adminPasswordHere
EOF
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      usage
      exit 0
      ;;
    --url)
      SERVER_URL="${2}"
      shift 2
      ;;
    -p|--port)
      SERVER_PORT="${2}"
      shift 2
      ;;
    -u|--username)
      PALWORLD_ADMIN_USER="${2}"
      shift 2
      ;;
    -P|--password)
      PALWORLD_ADMIN_PASSWORD="${2}"
      shift 2
      ;;
    *)
      echo "[ERROR] Invalid option: ${1}" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "${SERVER_URL}" ]]; then
  echo "[ERROR] Missing --url" >&2

  usage
  exit 1
fi

if [[ -z "${SERVER_PORT}" ]]; then
  echo "[ERROR] Missing --port" >&2

  usage
  exit 1
fi

if [[ -z "${PALWORLD_ADMIN_USER}" ]]; then
  echo "[ERROR] Missing --username" >&2
  
  usage
  exit 1
fi

if [[ -z "${PALWORLD_ADMIN_PASSWORD}" ]]; then
  echo "[ERROR] Missing --password" >&2
  
  usage
  exit 1
fi

URL="${SERVER_URL}:${SERVER_PORT}/v1/api/info"
echo "URL: ${URL}"

echo "Requesting Palworld server info"
curl --request GET \
  --url "${URL}" \
  --user "${PALWORLD_ADMIN_USER}:${PALWORLD_ADMIN_PASSWORD}"

echo

