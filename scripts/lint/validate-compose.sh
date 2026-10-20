#!/usr/bin/env bash
set -euo pipefail

############################################
# Validate compose.yml and overlay files   #
#                                          #
# Makes a best-effort guess at which YAML  #
# files should be validated. Attempts to   #
# find nearest compose.yml for overlays.   #
############################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

SCRIPT_NAME="./scripts/lint/validate-compose.sh"
DESCRIPTION="Validate Docker Compose files using docker compose config.

Only failed validations and their diagnostics are printed.
The final lines show how many files were checked and how many had failures.
Complete results are saved to the output directory."
EXAMPLES="  ${SCRIPT_NAME}
  ${SCRIPT_NAME} templates/media
  ${SCRIPT_NAME} templates/media/docker_jellyfin/compose.yml
  ${SCRIPT_NAME} --changed origin/main
  ${SCRIPT_NAME} --help"

if require_help_or_target "$@"; then
  show_help "${SCRIPT_NAME}" "${DESCRIPTION}" "${EXAMPLES}"
  exit 0
fi

## Accept --verbose for compatibility without printing successful files.
declare -a script_args=()
parse_verbose_flag "$@"

PATTERN='^.*/templates/.*compose[^/]*\.ya?ml$'

mapfile -t files < <(resolve_targets "${PATTERN}" "${script_args[@]}")

results_file="${OUTPUT_DIR}/compose-config.txt"
detailed_results_file="${OUTPUT_DIR}/compose-config-detailed.txt"

: >"${results_file}"
: >"${detailed_results_file}"

if ((${#files[@]} == 0)); then
  printf 'Files checked: 0\nFiles with failures: 0\n'
  exit 0
fi

JOBS="${COMPOSE_VALIDATE_JOBS:-$(nproc)}"

if [[ ! "${JOBS}" =~ ^[1-9][0-9]*$ ]]; then
  printf 'error: COMPOSE_VALIDATE_JOBS must be a positive integer.\n' >&2
  exit 2
fi

work_dir="$(mktemp -d "${OUTPUT_DIR}/compose-config-work.XXXXXX")"

trap 'rm -rf -- "${work_dir}"' EXIT

## Run independent Compose validations in parallel.
#  Workers write results to disk rather than printing to the console.
worker_status=0

printf '%s\0' "${files[@]}" |
  xargs -0 -n1 -P"${JOBS}" env \
    COMPOSE_VALIDATE_WORK_DIR="${work_dir}" \
    "${SCRIPT_DIR}/validate-compose-worker.sh" || worker_status=$?

failures=0
checked=0

for result in "${work_dir}"/*.result; do
  [[ -f "${result}" ]] || continue

  status="$(sed -n 's/^STATUS: //p' "${result}")"
  description="$(sed -n 's/^FILE: //p' "${result}")"

  ((checked += 1))

  ## Save one compact result per validation.
  printf '%s %s\n' "${status}" "${description}" >>"${results_file}"

  ## Preserve the command and complete Docker Compose output.
  {
    cat "${result}"
    printf '\n'
  } >>"${detailed_results_file}"

  ## Print only failed validations and their diagnostics.
  if [[ "${status}" == "FAIL" ]]; then
    ((failures += 1))

    printf 'FAIL %s\n' "${description}"

    ## Print everything after the OUTPUT marker.
    sed '1,/^OUTPUT:$/d' "${result}"

    printf '\n'
  fi
done

## Surface worker execution problems separately from validation failures.
if ((worker_status != 0)); then
  printf '[ERROR] One or more Compose validation workers could not complete.\n' >&2
fi

if ((checked != ${#files[@]})); then
  printf '[ERROR] Expected %d validation results, but received %d.\n' \
    "${#files[@]}" "${checked}" >&2
fi

## Print totals after all validation diagnostics.
printf '\nFiles checked: %d\nFiles with failures: %d\n' \
  "${checked}" "${failures}"

if ((failures > 0 || worker_status != 0 || checked != ${#files[@]})); then
  exit 1
fi

exit 0
