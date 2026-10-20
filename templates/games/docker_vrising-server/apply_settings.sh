#!/bin/bash

##
# After starting up a game, use this file to apply a configuration in configs/
# to the new game server
##

GAME_SETTINGS_FILE=$1
SERVER_SETTINGS_FILE=$2
CONFIGS_DIR="configs"
VRISING_SETTINGS_PERSIST_DIR="vrising/persist/Settings"

if [ -z "$SERVER_SETTINGS_FILE" ]; then
  SERVER_SETTINGS_FILE="ServerHostSettings.json"
fi

if [ -z "$GAME_SETTINGS_FILE" ]; then
  GAME_SETTINGS_FILE="ServerGameSettings.json"
fi

echo "Applying game settings file $CONFIGS_DIR/$GAME_SETTINGS_FILE to server $VRISING_SETTINGS_PERSIST_DIR/$GAME_SETTINGS_FILE"
if ! sudo cp -- \
  "$CONFIGS_DIR/$GAME_SETTINGS_FILE" \
  "$VRISING_SETTINGS_PERSIST_DIR/$GAME_SETTINGS_FILE"; then
  echo "[ERROR] Failed to copy $CONFIGS_DIR/$GAME_SETTINGS_FILE to $VRISING_SETTINGS_PERSIST_DIR/$GAME_SETTINGS_FILE" >&2
  exit 1
fi

echo "Applying server settings file $CONFIGS_DIR/$SERVER_SETTINGS_FILE to server $VRISING_SETTINGS_PERSIST_DIR/$SERVER_SETTINGS_FILE"
if ! sudo cp -- \
  "$CONFIGS_DIR/$SERVER_SETTINGS_FILE" \
  "$VRISING_SETTINGS_PERSIST_DIR/$SERVER_SETTINGS_FILE"; then
  echo "[ERROR] Failed to copy $CONFIGS_DIR/$SERVER_SETTINGS_FILE to $VRISING_SETTINGS_PERSIST_DIR/$SERVER_SETTINGS_FILE" >&2
  exit 1
fi
