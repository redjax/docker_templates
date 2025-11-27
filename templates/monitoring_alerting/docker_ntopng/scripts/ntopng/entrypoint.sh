#!/usr/bin/env bash
set -euo pipefail

## Split comma-separated interface list
IFS=',' read -r -a IFACES <<< "${NTOPNG_INTERFACES:-eth0}"

## Build -i arguments
NTOP_ARGS=()
for iface in "${IFACES[@]}"; do
  if ip link show "$iface" &>/dev/null; then
    NTOP_ARGS+=("-i" "$iface")
  else
    echo "Warning: interface $iface not found"
  fi
done

WEB_PORT=${NTOPNG_WEB_PORT:-8080}

## Execute ntopng directly (PID 1) with proper interface args
exec ntopng "${NTOP_ARGS[@]}" -w "$WEB_PORT"
