# Open Archiver

[Open Archiver](https://openarchiver.com/) is an open source email archiving & deDiscovery platform.

## Setup

- Copy the [example `.env` file](./.env.example) to `.env`
- Run [`./scripts/generate-secrets.sh`](./scripts/generate-secrets.sh)
- Pase the values from the secret generation script into the appropriate variables in `.env`.
  - You should also set the `APP_URL` to either an IP+port URL for local access, or behind a resolveable URL. This is also the URL you will use to access the webUI.
- When running all containers locally, use :

  ```shell
  docker compose \
    -f compose.yml \
    -f overlays/meilisearch.yml \
    -f overlays/postgres.yml \
    -f overlays/tika.yml \
    -f overlays/valkey.yml \
    up -d
  ```

- Navigate to the URL you put in `APP_URL` in the `.env` file, and put `/setup` at the end of the URL. This will take you to the admin user setup.
  - Example: `http://192.168.1.16:3000/setup`
