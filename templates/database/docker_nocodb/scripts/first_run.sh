#!/usr/bin/env bash

set -uo pipefail


echo "Doing NocoDB first run setup"
echo ""

while true; do
    read -n 1 -r -p "Are you using a host volume mount, i.e. ./data/nocodb:/usr/app/data ? (y/n) " yn

    case $yn in
        [Yy]*)
            echo ""
            echo "Creating ./data/nocodb/"
            mkdir -p ./data/{postgres,nocodb}
            echo ""
            break
            ;;
        [Nn]*)
            echo "Passing"
            break
            ;;
        *)
            echo "[ERROR] Invalid choice: $yn. Please use 'y' or 'n'"
            ;;
    esac
done
