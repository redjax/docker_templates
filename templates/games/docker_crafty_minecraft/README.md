# Crafty Minecraft Server

[Crafty](https://craftycontrol.com) is a server for running multiple Minecraft servers.

Crafty Controller is a free and open-source Minecraft launcher and manager that allows users to start and administer Minecraft servers from a user-friendly interface.

## Instructions

- Copy [`.env.example`](./.env.example) to `.env` and review the file, changing any values you want
- Run `docker compose up -d`
  - Running the container will create a directory at `./crafty`
  - Retrieve your default login credentials from the `./crafty/config/default-creds.txt` file
- Open the web UI at `https://your-ip-or-hostname:8443` and login using the credentials retrieved from the `default-creds.txt` file
  - If you changed the `CRAFTY_HTTPS_PORT` environment variable, use that port in the URL above instead of `:8443`

## Links

- [Crafty homepage](https://craftycontrol.com)
- [Crafty Gitlab](https://gitlab.com/crafty-controller/crafty-4)
- [Crafty docs](https://docs.craftycontrol.com)
  - [Crafty Docker install](https://docs.craftycontrol.com/pages/getting-started/installation/docker/)
  - [Crafty Docker Compose](https://docs.craftycontrol.com/pages/getting-started/installation/docker/#using-docker-compose)
