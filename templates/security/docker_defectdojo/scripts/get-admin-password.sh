#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "Error: docker is required." >&2
  exit 1
fi

password="$(
  docker compose logs --no-color initializer 2>&1 \
    | sed -n 's/.*Admin password:[[:space:]]*//p' \
    | tail -n 1
)"

if [[ -z "$password" ]]; then
  echo "Error: Admin password not found in initializer logs." >&2
  echo "The initializer may not have generated a password, or the logs may have rotated." >&2
  exit 1
fi

printf '%s\n' "$password"
