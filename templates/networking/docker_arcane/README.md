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

| Username | Password       |
| -------- | -------------- |
| `arcane` | `arcane-admin` |

## Troubleshooting

### Reset admin password

Temporarily set `ALLOW_CLI_PASSWORD_RESE=true` in the `.env` file. Restart the stack, then run:

```shell
docker compose exec arcane ./arcane admin reset-password --username arcane
```

If you're using the [`caddy.yml` layer](./overlays/caddy.yml), run this instead:

```shell
docker compose -f compose.yml -f overlays/caddy.yml \
  exec arcane ./arcane admin reset-password --username arcane
```

This will prompt you to set a new password for the `admin` user.
