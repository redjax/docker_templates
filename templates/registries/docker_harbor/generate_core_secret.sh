#!/usr/bin/env bash
set -euo pipefail

if ! command -v openssl &>/dev/null; then
  echo "[ERROR] openssl is not installed" >&2
  exit 1
fi

if ! openssl rand -hex 32; then
  echo "[ERROR] Failed generating secret" >&2
  exit 1
fi

