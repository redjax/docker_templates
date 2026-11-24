# Mindwtr

[Mindwtr](https://docs.mindwtr.app) is a free, open-source to-do app similar to Todoist.

This Compose stack is for the [Mindwtr Cloud component](https://docs.mindwtr.app/power-users/docker-deployment).

## Setup

- Copy the [example `.env` file](./.env.example) to `.env`
  - Set an access token in `MINDWTR_CLOUD_AUTH_TOKENS`
  - You can generate a token with `openssl rand -hex 32`, or by running [`./scripts/generate-secrets.sh`](./scripts/generate-secrets.sh).
  - If you are running the [Mindwtr PWA](./webapp), `MINDWTR_CLOUD_CORS_ORIGIN`
    to the URL you access the webapp from, i.e. `https://tasks.example.com` or `http://192.168.1.100:5173`
- Run `docker compose up -d`

There is no webUI, but you can check that the server is running by accessing `/health` or `/ready`. For example, if you're accessing the host internally on your LAN, check `http://192.168.1.100:8787/health`.

