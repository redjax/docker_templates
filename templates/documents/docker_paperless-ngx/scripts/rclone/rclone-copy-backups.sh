#!/usr/bin/env bash
set -euo pipefail

##################################################################
# Copy the nautical backup directory to an rclone remote         #
#                                                                #
# Initialize an rclone config with:                              #
#   rclone config --config "path/to/your/rclone.conf"            #
#                                                                #
# The default rclone config path is ~/.config/rclone/rclone.conf #
# If you generate a config in this path, you must always pass it #
# to rclone commands with --config "path/to/your/rclone.conf"    #
#                                                                #
# Encrypt the configuration by generating a password:            #
#   openssl rand -hex 32 > /path/to/.rclone.pass                 #
#                                                                #
# After generating the password, run:                            #
#   rclone config encryption set \                               #
#     --config ./scripts/rclone/rclone.conf \                    #
#     --password-command "cat ./scripts/rclone/.rclone.pass"     #
#                                                                #
# To run commands with the encrypted config, use the             #
# --password-command flag to 'cat' the contents of the file:     #
#                                                                #
# rclone listremotes \                                           #
#   --config path/to/your/rclone.conf \                          #
#   --password-command "cat /path/to/.rclone.pass"               #
##################################################################

CONFIG=""
PASSWORD_FILE=""
SOURCE=""
REMOTES=()

usage() {
  cat <<EOF
Usage:
  ${0##*/} [OPTIONS]

Options:
  -p, --password-file  <PATH>  Path to a file containing config decryption password (optional)
  -c, --config         <PATH>  Path to an rclone configuration file
  -h, --help                   Show this help menu

Arguments:
  source                       Local directory to back up
  remote                       One or more rclone remote destinations

Examples;
  ${0##*/} -c /some/path/to/rclone.conf /some/local/nautical/backup \\
    remote-name:path/in/remote \\
    another-destination:path/in/remote

  ${0##*/} -c ./rclone.conf -p ./rclone-password \\
    /some/local/backup/path \\
    remote-name:path/in/remote
EOF
}

## Parse options
while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--password-file)
      [[ $# -ge 2 && -n "$2" ]] || {
        echo "[ERROR] $1 requires a path" >&2
      exit 1
      }

      PASSWORD_FILE="$2"
      shift 2
      ;;
    -c|--config)
      [[ $# -ge 2 ]] || {
        echo "[ERROR] $1 requires a path" >&2
        exit 1
      }

      CONFIG="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "[ERROR] Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      break
      ;;
  esac
done

## Validate arguments

if [[ -z "$CONFIG" ]]; then
  _rclone_conf="${HOME}/.config/rclone/rclone.conf"
  if [[ -f "${_rclone_conf}" ]]; then
    echo "[WARNING] No --config given. Defaulting to ${_rclone_conf}" >&2
    CONFIG="${_rclone_conf}"
  else
    echo "[ERROR] --config is required" >&2
    usage >&2
    exit 1
  fi
fi

if [[ $# -lt 2 ]]; then
  echo "[ERROR] Source and at least one remote are required" >&2
  usage >&2
  exit 1
fi

SOURCE="$1"
shift
REMOTES=("$@")

## Validate configuration and source
if [[ ! -f "$CONFIG" ]]; then
  echo "[ERROR] Config file not found: $CONFIG" >&2
  exit 1
fi

if [[ ! -d "$SOURCE" ]]; then
  echo "[ERROR] Source directory not found: $SOURCE" >&2
  exit 1
fi

if ! command -v rclone >/dev/null 2>&1; then
  echo "[ERROR] rclone is not installed or not in PATH" >&2
  exit 1
fi

## Resolve source to an absolute path
SOURCE="$(cd "$SOURCE" && pwd)"

## Load the optional configuration password
CONFIG_PASSWORD=""

if [[ -n "$PASSWORD_FILE" ]]; then
  if [[ ! -f "$PASSWORD_FILE" || ! -r "$PASSWORD_FILE" ]]; then
    echo "[ERROR] Password file is not a readable regular file: $PASSWORD_FILE" >&2
    exit 1
  fi

  if ! CONFIG_PASSWORD="$(cat -- "$PASSWORD_FILE")"; then
    echo "[ERROR] Could not read password file: $PASSWORD_FILE" >&2
    exit 1
  fi

  if [[ -z "$CONFIG_PASSWORD" ]]; then
    echo "[ERROR] Password file is empty: $PASSWORD_FILE" >&2
    exit 1
  fi
fi

## Supply the password only to rclone, and only when a file was provided
run_rclone() {
  if [[ -n "$PASSWORD_FILE" ]]; then
    RCLONE_CONFIG_PASS="$CONFIG_PASSWORD" rclone "$@"
  else
    rclone "$@"
  fi
}

## Copy to each remote
FAILED=0

for REMOTE in "${REMOTES[@]}"; do
  echo
  echo "========================================"
  echo "Backing up: $SOURCE"
  echo "Destination: $REMOTE"
  echo "========================================"

  if ! run_rclone copy \
    --config "$CONFIG" \
    "$SOURCE" \
    "$REMOTE" \
    --progress \
    --create-empty-src-dirs 2>&1; then
    echo "[ERROR] Failed backing up source '$SOURCE' to destination '$REMOTE'" >&2
    FAILED=1
    continue
  fi

  echo "Completed: $REMOTE"
done

unset CONFIG_PASSWORD

echo
if [[ "$FAILED" -ne 0 ]]; then
  echo "[ERROR] One or more backups failed." >&2
  exit 1
fi

echo "All backups completed successfully."

