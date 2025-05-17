# Custom Settings

After starting the server with Docker Compose, copy the settings from one of the files in this path to `../vrising/persist/Settings/`. There are 2 settings files, `ServerGameSettings.json` (options for gameplay like castle decay & teleporting with bound items) and `ServerHostSettings.json` (server configuration like game/world name and game mode).

Restart the container to apply the settings.

## Apply with script

You can also use the [`apply_settings.sh` script](../apply_settings.sh) to copy the settings files into the persist directory. First, start the server with `docker compose up -d`. This creates the 'persist' path. If you want to store the files locally, edit the [`.env` file](../.env.example), changing the `VRISING_SERVER_PERSIST_DIR` variable to a local path, i.e. `VRISING_SERVER_PERSIST_DIR=./vrising/persist`

In the `persist/` directory there will be a `Settings/` directory with a `ServerGameSettings.json` and `ServerHostSettings.json`. The script accepts 2 arguments, the first one being the game settings and the second being the server. Copy a configuration from [`premade/`](./premade) to `./ServerGameSettings.json`/`./ServerHostSettings.json`, then run the script. The script will take the contents of the settings file and apply them to the `persist/Settings/` directory.

After running the `apply_settings.sh` script, restart the Docker server with `docker compose up -d --force-recreate`.
