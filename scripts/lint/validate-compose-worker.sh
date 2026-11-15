#!/usr/bin/env bash
set -euo pipefail

############################################
# Validate one Docker Compose YAML file.   #
#                                          #
# Writes a self-contained result file.     #
############################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

VERBOSE="${COMPOSE_VALIDATE_VERBOSE:-false}"

file="${1:?usage: validate-compose-worker.sh FILE}"
relative="${file#"${REPO_ROOT}/"}"

result_id="$(printf '%s' "${relative}" | md5sum | cut -d' ' -f1)"
result_file="${COMPOSE_VALIDATE_WORK_DIR}/${result_id}.result"

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

write_result() {
  local status="$1"
  local description="$2"
  local command="$3"
  local output_file="$4"

  {
    printf 'STATUS: %s\n' "${status}"
    printf 'FILE: %s\n' "${description}"
    printf 'COMMAND: %s\n' "${command}"
    printf 'OUTPUT:\n'
    cat "${output_file}"
  } >"${result_file}"
}

output_file="$(mktemp)"

## First try the file as a standalone Compose project.
standalone_command="docker compose -f ${file} config -q"

if [[ "${VERBOSE}" == true ]]; then
  printf '==> %s\n' "${standalone_command}" >&2
fi

if docker compose -f "$file" config -q >"${output_file}" 2>&1; then
  write_result "PASS" "${relative}" "${standalone_command}" "${output_file}"
  rm -f "${output_file}"
  exit 0
fi

## If it is not standalone-valid, try it as an overlay against the nearest
#  ancestor Compose file.
if parent_compose="$(find_parent_compose "$file")"; then
  if [[ "${parent_compose}" != "${file}" ]]; then
    parent_relative="${parent_compose#"${REPO_ROOT}/"}"
    overlay_description="${parent_relative} + ${relative}"
    overlay_command="docker compose -f ${parent_compose} -f ${file} config -q"

    if [[ "${VERBOSE}" == true ]]; then
      printf '==> %s\n' "${overlay_command}" >&2
    fi

    if docker compose -f "$parent_compose" -f "$file" config -q >"${output_file}" 2>&1; then
      write_result "PASS" "${overlay_description}" "${overlay_command}" "${output_file}"
      rm -f "${output_file}"
      exit 0
    fi
  fi
fi

write_result "FAIL" "${relative}" "${standalone_command}" "${output_file}"
rm -f "${output_file}"

exit 0
