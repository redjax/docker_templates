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
cat $CONFIGS_DIR/$GAME_SETTINGS_FILE | sudo tee "$VRISING_SETTINGS_PERSIST_DIR/$GAME_SETTINGS_FILE" > /dev/null 2>&1
if [[ $? != 0 ]]; then
    echo "Failed to apply game settings file $GAME_SETTINGS_FILE to server $GAME_SETTINGS_FILE"
    exit 1
fi

echo "Applying server settings file $CONFIGS_DIR/$SERVER_SETTINGS_FILE to server $VRISING_SETTINGS_PERSIST_DIR/$SERVER_SETTINGS_FILE"
cat $CONFIGS_DIR/$SERVER_SETTINGS_FILE | sudo tee "$VRISING_SETTINGS_PERSIST_DIR/$SERVER_SETTINGS_FILE" > /dev/null 2>&1
if [[ $? != 0 ]]; then
    echo "Failed to apply server settings file $SERVER_SETTINGS_FILE to server $SERVER_SETTINGS_FILE"
    exit 1
fi
