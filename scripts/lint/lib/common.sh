#!/usr/bin/env bash
set -euo pipefail

############################################
# Common/shared utilities for lint scripts #
############################################

REPO_ROOT="$(git rev-parse --show-toplevel)"
OUTPUT_DIR="${REPO_ROOT}/output/lint-results"

mkdir -p "${OUTPUT_DIR}"

VERBOSE=false

## Each script can pass its own values to show a help menu
show_help() {
  local script_name="${1}"
  local description="${2}"
  local examples="${3}"

  cat <<EOF
${script_name}

${description}

Usage:
  ${script_name} [OPTIONS] [PATH | FILE]

Options:
  -h, --help           Show this help message and exit.
  -v, --verbose        Show underlying commands and successful tool output.
      --changed REF    Only process files changed between REF and HEAD.

Arguments:
  PATH                 Process matching files beneath a directory.
  FILE                 Process one specific file.
  (none)               Process matching files beneath templates/.

Examples:
  ${examples}
EOF
}

require_help_or_target() {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    return 0
  fi

  return 1
}

## Removes -v/--verbose from script arguments and sets VERBOSE when present.
parse_verbose_flag() {
  VERBOSE=false
  script_args=()

  for arg in "$@"; do
    case "${arg}" in
    -v | --verbose)
      VERBOSE=true
      ;;
    *)
      script_args+=("${arg}")
      ;;
    esac
  done
}

resolve_targets() {
  local pattern="$1"
  shift

  if [[ "${1:-}" == "--changed" ]]; then
    if [[ $# -lt 2 ]]; then
      echo "error: --changed requires a Git ref, e.g. --changed origin/main" >&2
      exit 2
    fi

    local base_ref="$2"

    git diff --name-only --diff-filter=ACMR "${base_ref}"...HEAD |
      grep -E "${pattern}" |
      sed "s|^|${REPO_ROOT}/|" |
      sort -u
  elif [[ $# -eq 0 ]]; then
    find "${REPO_ROOT}/templates" -type f -regextype posix-extended -regex "${pattern}" | sort
  elif [[ -f "$1" ]]; then
    printf '%s\n' "$1"
  elif [[ -d "$1" ]]; then
    find "$1" -type f -regextype posix-extended -regex "${pattern}" | sort
  else
    echo "error: path does not exist: $1" >&2
    exit 2
  fi
}

print_summary() {
  local label="$1"
  local checked="$2"
  local failed="$3"

  printf '\n%s\n' "${label}"
  printf 'Checked: %s\n' "${checked}"
  printf 'Failed:  %s\n' "${failed}"

  if ((failed > 0)); then
    exit 1
  fi
}

run_tool() {
  local label="$1"
  shift

  if [[ "$VERBOSE" == true ]]; then
    printf '==> %s\n' "$*" >&2
  fi

  "$@"
}
