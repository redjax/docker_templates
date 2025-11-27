#!/usr/bin/env bash
set -euo pipefail

## Convert comma-separated list to multiple -i args
IFS=',' read -r -a INTERFACES <<< "${NTOPNG_INTERFACES:-eth0}"
NTOP_ARGS=()
for iface in "${INTERFACES[@]}"; do
  NTOP_ARGS+=("-i" "$iface")
done

WEB_PORT=${NTOPNG_WEB_PORT:-8080}

exec ntopng "${NTOP_ARGS[@]}" -w "$WEB_PORT" "$@"
