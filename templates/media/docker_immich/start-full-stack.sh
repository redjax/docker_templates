#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker >&/dev/null; then
  echo "[ERROR] Docker is not installed." >&2
  exit 1
fi

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

compose_files=(
  "compose.yml"
  "overlays/postgres.yml"
  "overlays/redis.yml"
  "overlays/web.yml"
)

cmd=(docker compose)

for c in "${compose_files[@]}"; do
  cmd+=(-f "${c}")
done

cmd+=(up -d)

echo "Command:"
echo "  ${cmd[*]}"

"${cmd[@]}"
