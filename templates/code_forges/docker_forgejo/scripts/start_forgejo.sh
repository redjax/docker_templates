#!/bin/bash

if ! command -v docker > /dev/null 2>&1; then
    echo "[ERROR] docker is not installed"
    exit 1
fi

if [[ ! -f ".env" ]]; then
    echo "[ERROR] .env file not found at path '$(pwd)/.env'"
    exit 1
fi

START_CMD=""
START_MSG=""
AUTH_OVERLAY=""
TRAEFIK_OVERLAY=""
DRY_RUN=""

## Read args
while [[ $# -gt 0 ]]; do
    case $1 in
        --auth)
        #   echo "Starting Forgejo with Authentik overlay"
          AUTH_OVERLAY="true"
          ;;
        --traefik)
        #   echo "Starting Forgejo with Traefik overlay"
          TRAEFIK_OVERLAY="true"
          ;;
        --dry-run)
          echo "Dry run enabled"
          DRY_RUN="true"
          ;;
        -h|--help)
          echo "Usage: $0 [--auth] [--traefik] [--dry-run]"
          exit 0
          ;;
        *)
          echo "Unknown argument: $1"
          echo ""
          echo "Usage: $0 [--auth] [--traefik] [--dry-run]"
          exit 1
          ;;
    esac
    shift
done

if [[ -n "$AUTH_OVERLAY" ]]; then
    if [[ -n "$TRAEFIK_OVERLAY" ]]; then
        START_MSG="Starting Forgejo with Authentik overlay and Traefik overlay"
        START_CMD="docker compose -f compose.yml -f overlay.authentik.yml -f overlay.traefik.yml up -d"
    else
        echo "Starting Forgejo with Authentik overlay"
        START_CMD="docker compose -f compose.yml -f overlay.auth.yml up -d"
    fi
elif [[ -n "$TRAEFIK_OVERLAY" ]]; then
    START_MSG="Starting Forgejo with Traefik overlay"
    START_CMD="docker compose -f compose.yml -f overlay.traefik.yml up -d"
else
    START_MSG="Starting Forgejo server"
    START_CMD="docker compose up -d"
fi

if [[ -z "$START_CMD" ]]; then
    echo "[ERROR] No start command specified"
    exit 1
fi

echo "${START_MSG}"
echo "  Command: $START_CMD"
if [[ -n "$DRY_RUN" ]]; then
    echo "  Dry-run mode enabled. Run without --dry-run to execute this command."
else
    eval $START_CMD
    if [[ $? -ne 0 ]]; then
        echo "[ERROR] Failed to start Forgejo"
        exit $?
    fi
fi
