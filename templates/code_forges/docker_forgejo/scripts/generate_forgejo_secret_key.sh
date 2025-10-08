#!/bin/bash

set -e

if ! command -v docker 2>&1 > /dev/null; then
    echo "[ERROR] docker is not installed"
    exit 1
fi

echo "Generating Forgejo secret key"
echo ""
docker run --rm codeberg.org/forgejo/forgejo:11 forgejo generate secret SECRET_KEY
if [[ $? -ne 0 ]]; then
    echo "[ERROR] Failed to generate Forgejo secret key"
    exit 1
fi

echo ""
echo ""
echo "Forgejo secret key generated successfully"
echo "Edit your Forgejo env file and set FORGEJO__secret__SECRET_KEY to the generated key"
exit 0
