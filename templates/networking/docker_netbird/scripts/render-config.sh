#!/usr/bin/env bash
set -euo pipefail

#############################################
# Generate the secrets required for Netbird #
#############################################

THIS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(realpath "${THIS_DIR}/..")"

CONFIG_TEMPLATE="${REPO_ROOT}/config.yaml.template"
CONFIG_RENDERED="${REPO_ROOT}/config.yaml"

DASHBOARD_TEMPLATE="${REPO_ROOT}/dashboard.env.template"
DASHBOARD_RENDERED="${REPO_ROOT}/dashboard.env"

: "${NETBIRD_DOMAIN:?missing NETBIRD_DOMAIN}"
: "${NETBIRD_AUTH_SECRET:?missing NETBIRD_AUTH_SECRET}"
: "${NETBIRD_STORE_ENCRYPTION_KEY:?missing NETBIRD_STORE_ENCRYPTION_KEY}"

echo "[INFO] Rendering NetBird templates"

## Render config.yaml
if [[ ! -f "${CONFIG_TEMPLATE}" ]]; then
  echo "[ERROR] Missing config template: ${CONFIG_TEMPLATE}" >&2
  exit 1
fi

envsubst < "${CONFIG_TEMPLATE}" > "${CONFIG_RENDERED}"
echo "[OK] Wrote ${CONFIG_RENDERED}"

## Render dashboard.env
if [[ ! -f "${DASHBOARD_TEMPLATE}" ]]; then
  echo "[ERROR] Missing dashboard template: ${DASHBOARD_TEMPLATE}" >&2
  exit 1
fi

envsubst < "${DASHBOARD_TEMPLATE}" > "${DASHBOARD_RENDERED}"
echo "[OK] Wrote ${DASHBOARD_RENDERED}"

echo "[DONE] All NetBird templates rendered"

