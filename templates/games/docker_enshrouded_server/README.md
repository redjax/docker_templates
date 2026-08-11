# Enshrouded Server

Dockerized server for Enshrouded.

## Usage

After starting up the container stack, bring it down the first time with `docker compose down` (you can do this as soon as the `enshrouded_server.json` file appears) and edit the `enshrouded_server.json` the game creates in the directory you set for `ENSHROUDED_DATA_DIR`. Find the option `gameSettingsPreset`, and set it to `"Custom"`. If this option doesn't exist, add it manually.

## Links

- [Github: enshrouded-docker](https://github.com/mbround18/enshrouded-docker)
