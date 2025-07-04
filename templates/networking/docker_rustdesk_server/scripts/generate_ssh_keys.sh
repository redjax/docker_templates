#!/bin/bash

if ! command -v ssh-keygen &>/dev/null; then
  echo "SSH is not installed."
  exit 1
fi

echo "Generating SSH key"
ssh-keygen -t ed25519 -f id_ed25519 -N ""
