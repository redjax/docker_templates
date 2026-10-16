#!/usr/bin/env bash
set -euo pipefail

############################################
# Validate compose.yml and overlay files   #
#                                          #
# Makes a best-effort guess at which YAML  #
# files should be linted. Attempts to find #
# nearest compose.yml for overlays.        #
############################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

SCRIPT_NAME="./scripts/lint/validate-compose.sh"
DESCRIPTION="Validate Docker Compose files using docker compose config."
EXAMPLES="  ${SCRIPT_NAME}
  ${SCRIPT_NAME} templates/media
  ${SCRIPT_NAME} templates/media/docker_jellyfin/compose.yml
  ${SCRIPT_NAME} --changed origin/main
  ${SCRIPT_NAME} --help"

if require_help_or_target "$@"; then
  show_help "${SCRIPT_NAME}" "${DESCRIPTION}" "${EXAMPLES}"
  exit 0
fi

PATTERN='^.*/templates/.*compose[^/]*\.ya?ml$'

mapfile -t files < <(resolve_targets "${PATTERN}" "$@")

if ((${#files[@]} == 0)); then
  echo "No Compose files found."
  exit 0
fi

failures=0
checked=0
results_file="${OUTPUT_DIR}/compose-config.txt"
last_result_file="${OUTPUT_DIR}/compose-config-last.txt"

: >"${results_file}"

run_compose_config() {
  local description="$1"
  shift

  ((checked += 1))

  {
    printf '\n==> %s\n' "${description}"
    printf '$ docker compose %s config -q\n' "$*"
  } >>"${results_file}"

  if docker compose "$@" config -q >>"${results_file}" 2>&1; then
    printf 'PASS %s\n' "${description}"
    printf 'PASS\n' >>"${results_file}"
    return 0
  fi

  printf 'FAIL\n' >>"${results_file}"
  cp "${results_file}" "${last_result_file}"

  return 1
}

find_parent_compose() {
  local start_dir="$1"

  local current_dir
  current_dir="$(dirname "$start_dir")"

  while [[ "$current_dir" != "$REPO_ROOT" && "$current_dir" != "/" ]]; do
    for candidate in compose.yml compose.yaml; do
      if [[ -f "${current_dir}/${candidate}" ]]; then
        printf '%s\n' "${current_dir}/${candidate}"
        return 0
      fi
    done

    current_dir="$(dirname "$current_dir")"
  done

  return 1
}

for file in "${files[@]}"; do
  relative="${file#"${REPO_ROOT}/"}"

  if run_compose_config "${relative}" -f "$file"; then
    continue
  fi

  ## The file is not standalone-valid. Try it as an overlay against the
  #  nearest ancestor Compose file.
  if parent_compose="$(find_parent_compose "$file")"; then
    parent_relative="${parent_compose#"${REPO_ROOT}/"}"
    overlay_description="${parent_relative} + ${relative}"

    if run_compose_config "${overlay_description}" -f "$parent_compose" -f "$file"; then
      continue
    fi
  fi

  printf 'FAIL %s\n' "${relative}"
  cat "${results_file}" >&2
  ((failures += 1))
done

print_summary "docker compose config" "${checked}" "${failures}"
