#!/usr/bin/env bash
set -uo pipefail

## Path to directory this script exists in
this_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(realpath -m "$this_dir/../..")"

container_name="filebrowser"

while [[ $# -gt 0 ]]; do
  case $1 in
    -n|--container-name)
      if [[ -z "$2" ]]; then
        echo "[ERROR] --container-name provided, but no container name given."
        exit 1
      fi

      container_name="$2"
      shift
      ;;
    -h|--help)
      echo ""
      echo "Usage: ${0} [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  -n, --container-name  Name of the NocoDB Docker container. Default: ${container_name}"
      echo "  -h, --help            Print this help menu."
      echo ""

      exit 0
      ;;
    *)
      echo "[ERROR] Invalid argument: $1"
      exit 1
      ;;
  esac
done

if ! docker logs "$container_name" 2>&1 | grep -i "password\|admin" | grep -v "grep"; then
  echo "[INFO] No password in logs - try default admin/admin or reset:"
  echo "  docker exec -it $container_name filebrowser users update admin --password newpass"
fi