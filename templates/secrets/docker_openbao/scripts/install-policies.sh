#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="openbao"
POLICY_DIR="${POLICY_DIR:-./config/policies}"
declare -a SELECTED_POLICIES=()

FORCE=0
POLICIES_TO_INSTALL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
  -f | --force)
    FORCE=1
    shift
    ;;
  -p | --policy)
    if [[ -z "${2:-}" ]]; then
      echo "[ERROR] --policy requires a path argument"
      exit 1
    fi
    POLICIES_TO_INSTALL+=("$2")
    shift 2
    ;;
  -*)
    echo "[ERROR] Unknown option: $1"
    exit 1
    ;;
  *)
    echo "[ERROR] Unexpected argument: $1"
    exit 1
    ;;
  esac
done

if ! docker compose ps --services | grep -q "^${CONTAINER_NAME}$"; then
  echo "[ERROR] Container '${CONTAINER_NAME}' is not running"
  exit 1
fi

FILES_TO_CONSIDER=()

if [ "${#POLICIES_TO_INSTALL[@]}" -gt 0 ]; then
  ## User provided specific files
  for f in "${POLICIES_TO_INSTALL[@]}"; do

    if [[ ! -f "$f" ]]; then
      echo "[WARN] File '$f' does not exist, skipping"
      continue
    fi

    FILES_TO_CONSIDER+=("$f")

  done
else
  ## Recursively scan POLICY_DIR
  while IFS= read -r -d '' file; do
    FILES_TO_CONSIDER+=("$file")
  done < <(find "$POLICY_DIR" -type f -name "*.hcl" ! -name "*example*.hcl" -print0)
fi

if [ "${#FILES_TO_CONSIDER[@]}" -eq 0 ]; then
  echo "[INFO] No policy files found to install"
  exit 0
fi

for f in "${FILES_TO_CONSIDER[@]}"; do
  if [[ "$FORCE" -eq 1 ]]; then
    SELECTED_POLICIES+=("$f")
  else
    echo ""
    read -n 1 -r -p "Install policy '$f'? [y/N]: " yn
    echo ""

    case "$yn" in
    [Yy]*) SELECTED_POLICIES+=("$f") ;;
    *) echo "Skipping $f" ;;
    esac
  fi
done

if [ "${#SELECTED_POLICIES[@]}" -eq 0 ]; then
  echo "[INFO] No policies selected for installation"
  exit 0
fi

echo ""
echo "Installing policies"
for policy_file in "${SELECTED_POLICIES[@]}"; do
  ## Use the basename without extension as policy name
  policy_name=$(basename "$policy_file" .hcl)
  echo "Installing policy '$policy_name' from '$policy_file'"

  if ! docker compose exec -it "$CONTAINER_NAME" bao policy write "$policy_name" "/etc/openbao/policies/$(basename "$policy_file")"; then
    echo "[WARN] Failed to install policy '$policy_name'" >&2
  fi
done

SELECTED_COUNT="${#SELECTED_POLICIES[@]}"

if [[ "$SELECTED_COUNT" -gt 1 ]]; then
  echo ""
  echo "Installed $SELECTED_COUNT policies:"

  for policy_file in "${SELECTED_POLICIES[@]}"; do
    ## Use the basename without extension as policy name
    policy_name=$(basename "$policy_file" .hcl)
    echo "  - $policy_name"
  done

else
  echo ""
  echo "Installed $SELECTED_COUNT policy:"
  policy_file="${SELECTED_POLICIES[0]}"

  ## Use the basename without extension as policy name
  policy_name=$(basename "$policy_file" .hcl)
  echo "- $policy_name"
fi
