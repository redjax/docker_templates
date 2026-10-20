#!/bin/bash

prompt_yes_no() {
  local prompt_message=$1
  local user_input
  while true; do
    read -r -p "$prompt_message (y/n): " user_input
    echo

    case $user_input in
    [Yy]*)
      echo "yes"
      break
      ;;
    [Nn]*)
      echo "no"
      break
      ;;
    *) echo "Invalid input. Please enter 'y' or 'n'." ;;
    esac
  done
}

if ! docker compose version >/dev/null 2>&1; then
  echo "[ERROR] Docker Compose is not installed."
  exit 1
fi

## Prompt for username
read -r -p "New username: " USERNAME
echo

## Prompt if the user should be an admin
IS_ADMIN=$(prompt_yes_no "Should this user be a ntfy admin?")

## Prompt if an access token should be created
CREATE_TOKEN=$(prompt_yes_no "Should an access token be created for this user?")

## Prompt for expiration period
read -r -p "Enter expiration period for the token (i.e. 90d, 30d, or an empty string for never): " EXPIRATION
echo

## Prompt for label (allow empty/null values)
read -r -p "Enter a label for the token (optional, press Enter to skip): " LABEL
echo

## Build the `docker compose exec` command
DOCKER_COMMAND="docker compose exec -it ntfy ntfy user add"
if [ "$IS_ADMIN" == "yes" ]; then
  DOCKER_COMMAND+=" --role=admin"
fi
DOCKER_COMMAND+=" $USERNAME"

echo "[DEBUG] Executing: $DOCKER_COMMAND"
if ! "${DOCKER_COMMAND}" 2>&1; then
  echo "[ERROR] Failed to create ntfy user: $USERNAME"
  exit 1
else
  echo "[SUCCESS] Created ntfy user: $USERNAME"
fi

## If token creation is enabled, build and execute the token command
if [ "$CREATE_TOKEN" == "yes" ]; then
  TOKEN_COMMAND="docker compose exec -it ntfy ntfy token add --expires=$EXPIRATION"
  if [ -n "$LABEL" ]; then
    TOKEN_COMMAND+=" --label=\"$LABEL\""
  fi
  TOKEN_COMMAND+=" $USERNAME"

  echo "[DEBUG] Executing: $TOKEN_COMMAND"
  if ! "${TOKEN_COMMAND}" 2>&1; then
    echo "[ERROR] Failed to create access token for user: $USERNAME"
    exit 1
  else
    echo "[SUCCESS] Created access token for user: $USERNAME"
  fi
fi

exit 0
