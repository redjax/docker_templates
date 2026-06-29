#!/usr/bin/env bash
set -uo pipefail

if ! command -v docker &>/dev/null; then
    echo "[ERROR] Docker is not installed."
    exit 1
fi

# Defaults
NAME=""
EMAIL=""
USERNAME=""
PASSWORD=""

## Parse CLI options
OPTIONS=n:u:e:
LONGOPTIONS=name:,username:,email:

## - Temporarily store output to handle quoting correctly
PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTIONS --name "$0" -- "$@")
if [[ $? -ne 0 ]]; then
    echo "Failed to parse options." >&2
    exit 1
fi

## Read getopt output into positional parameters
eval set -- "$PARSED"

## Extract options and their arguments into variables
while true; do
    case "$1" in
    -n | --name)
        NAME="$2"
        shift 2
        ;;
    -u | --username)
        USERNAME="$2"
        shift 2
        ;;
    -e | --email)
        EMAIL="$2"
        shift 2
        ;;
    --)
        shift
        break
        ;;
    *)
        echo "Unexpected option $1"
        exit 1
        ;;
    esac
done

## Function to prompt if empty
prompt_if_empty() {
    local var_name=$1
    local prompt_msg=$2
    local is_password=${3:-false}
    local value=$(eval echo \$$var_name)
    if [[ -z $value ]]; then
        if [[ $is_password == true ]]; then
            read -rsp "$prompt_msg: " input_val
            echo
        else
            read -rp "$prompt_msg: " input_val
        fi
        eval $var_name="'$input_val'"
    fi
}

## Prompt user for missing values
prompt_if_empty NAME "Enter name"
prompt_if_empty USERNAME "Enter username"
prompt_if_empty EMAIL "Enter email"
prompt_if_empty PASSWORD "Enter password" true

echo ""
echo "Dozzle user YAML below:"
echo ""

## Run the Docker command with collected values
docker run -it --rm amir20/dozzle generate \
    --name "$NAME" \
    --email "$EMAIL" \
    --password "$PASSWORD" \
    "$USERNAME"
