# Arcane

[Arcane](https://getarcane.app/) is a Docker management suite. It can monitor and update Docker containers running on remote machines.

## Setup

- Copy the [example `.env` file](./.env.example) to `.env`
  - Set your timezone in `TZ`
  - Optionally change the user the container runs as by editing `PUID`/`PGID`
- Generate an an app secret with [`./generate_secrets.sh`](./generate_secrets.sh)
  - Copy the value into the `.env` file
- Run `docker compose up -d`

You can open the Arcane dashboard by navigating to `http(s)://your-ip-or-hostname:3552`. The default admin login is:

| Username | Password |
| -------- | -------- |
|`arcane`  | `arcane-admin` |

