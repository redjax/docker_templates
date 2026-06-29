#!/bin/bash

set -e

if ! command -v docker 2>&1 > /dev/null; then
    echo "[ERROR] docker is not installed"
    exit 1
fi

echo "Generating Forgejo internal token"
echo ""
docker run --rm codeberg.org/forgejo/forgejo:11 forgejo generate secret INTERNAL_TOKEN
if [[ $? -ne 0 ]]; then
    echo "[ERROR] Failed to generate Forgejo internal token"
    exit 1
fi

echo ""
echo ""
echo "Forgejo internal token generated successfully"
echo "Edit your Forgejo env file and set FORGEJO__secret__INTERNAL_TOKEN to the generated key"
exit 0
