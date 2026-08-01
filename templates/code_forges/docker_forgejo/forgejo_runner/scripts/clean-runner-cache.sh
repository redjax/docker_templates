#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

# Load .env if present
if [[ -f .env ]]; then
    set -a
    source .env
    set +a
fi

COMPOSE="docker compose"

echo "[+] Stopping runner"
echo
$COMPOSE down

if [[ -n "${FORGEJO_RUNNER_CACHE_DIR:-}" ]]; then
    echo "[+] Removing cache directory: ${FORGEJO_RUNNER_CACHE_DIR}"
    echo
    rm -rf -- "${FORGEJO_RUNNER_CACHE_DIR}"
else
    VOLUME="${FORGEJO_RUNNER_CACHE_VOLUME:-forgejo-runner_cache}"

    echo "[+] Removing named volume: $VOLUME"
    echo
    docker volume rm -f "$VOLUME" || true
fi

echo
echo "[+] Restarting runner"
echo

$COMPOSE up -d
