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
  ${SCRIPT_NAME} --verbose
  ${SCRIPT_NAME} --help"

if require_help_or_target "$@"; then
  show_help "${SCRIPT_NAME}" "${DESCRIPTION}" "${EXAMPLES}"
  exit 0
fi

mapfile -d '' -t script_args < <(parse_verbose_flag "$@")

PATTERN='^.*/templates/.*compose[^/]*\.ya?ml$'

mapfile -t files < <(resolve_targets "${PATTERN}" "${script_args[@]}")

if ((${#files[@]} == 0)); then
  echo "No Compose files found."
  exit 0
fi

JOBS="${COMPOSE_VALIDATE_JOBS:-$(nproc)}"
work_dir="${OUTPUT_DIR}/compose-config-work"
results_file="${OUTPUT_DIR}/compose-config.txt"

JOBS="${COMPOSE_VALIDATE_JOBS:-$(nproc)}"
work_dir="${OUTPUT_DIR}/compose-config-work"
results_file="${OUTPUT_DIR}/compose-config.txt"
detailed_results_file="${OUTPUT_DIR}/compose-config-detailed.txt"

rm -rf "${work_dir}"
mkdir -p "${work_dir}"

echo "Linting Docker Compose files. Results will print soon. The terminal may appear frozen, but it's not."

## Run independent Compose validations in parallel.
printf '%s\0' "${files[@]}" |
  xargs -0 -n1 -P"${JOBS}" env \
    COMPOSE_VALIDATE_WORK_DIR="${work_dir}" \
    COMPOSE_VALIDATE_VERBOSE="${VERBOSE}" \
    "${SCRIPT_DIR}/validate-compose-worker.sh"

## Initialize output logs.
: >"${results_file}"
: >"${detailed_results_file}"

failures=0
checked=0

for result in "${work_dir}"/*.result; do
  [[ -f "${result}" ]] || continue

  status="$(sed -n 's/^STATUS: //p' "${result}")"
  description="$(sed -n 's/^FILE: //p' "${result}")"

  ((checked += 1))

  ## Compact, stable result log.
  printf '%s %s\n' "${status}" "${description}" >>"${results_file}"

  ## Full command and Docker Compose output.
  cat "${result}" >>"${detailed_results_file}"

  if [[ "${status}" == "FAIL" ]]; then
    ((failures += 1))

    if [[ "${VERBOSE}" == true ]]; then
      printf 'FAIL %s\n' "${description}"
    fi

    if [[ "${VERBOSE}" == true ]]; then
      cat "${result}"
    fi
  elif [[ "${VERBOSE}" == true ]]; then
    printf 'PASS %s\n' "${description}"
    cat "${result}"
  fi
done

rm -rf "${work_dir}"

print_summary "docker compose config" "${checked}" "${failures}"
