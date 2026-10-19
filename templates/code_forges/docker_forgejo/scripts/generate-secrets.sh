#!/usr/bin/env bash

if ! command -v docker >/dev/null 2>&1; then
  echo "[ERROR] docker is not installed" >&2
  exit 1
fi

if ! command -v openssl >/dev/null 2>&1; then
  echo "[ERROR] openssl is not installed" >&2
  exit 1
fi

FORGEJO_VER=${FORGEJO_IMG_VER:-15}

function forgejo_secret_key() {
  local key

  key=$(docker run --rm codeberg.org/forgejo/forgejo:${FORGEJO_VER} forgejo generate secret SECRET_KEY)
  echo "${key}"
  
}

function forgejo_internal_token() {
  local token

  token=$(docker run --rm codeberg.org/forgejo/forgejo:${FORGEJO_VER} forgejo generate secret INTERNAL_TOKEN)
  echo "${token}"
}

function authentik_secret() {
  local secret

  secret=$(openssl rand -base64 60 | tr -dc 'A-Za-z0-9')
  echo "${secret}"
}

echo "FORGEJO__secret__SECRET_KEY=$(forgejo_secret_key)"
echo "FORGEJO__secret__INTERNAL_TOKEN=$(forgejo_internal_token)"
echo "AUTHENTIK_SECRET_KEY=$(authentik_secret)"
echo "AUTHENTIK_DB_PASS=$(authentik_secret)"

