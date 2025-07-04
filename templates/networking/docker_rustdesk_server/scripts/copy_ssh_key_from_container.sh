#!/bin/bash

KEY_NAME="id_ed25519"
CONTAINER_PRIVKEY_PATH="/root/${KEY_NAME}"
CONTAINER_PUBKEY_PATH="/root/${KEY_NAME}.pub"
HOST_PATH="$(pwd)/.backup"

if [[ ! -d "$HOST_PATH" ]]; then
  mkdir -p "$HOST_PATH"

  if [[ $? -ne 0 ]]; then
    echo "Error creating host dir: $HOST_PATH"
    exit $?
  fi
fi

echo "Copying SSH key from existing RustDesk container"

docker compose cp hbbs:$CONTAINER_PRIVKEY_PATH "${HOST_PATH}/${KEY_NAME}"
if [[ $? -ne 0 ]]; then
  echo "Error copying private key out of container."
  exit $?
fi

docker compose cp hbbs:$CONTAINER_PUBKEY_PATH "${HOST_PATH}/${KEY_NAME}.pub"
if [[ $? -ne 0 ]]; then
  echo "Error copying public key out of container."

  exit $?
fi

echo "Copied SSH keys to: ${HOST_PATH}"
exit 0
