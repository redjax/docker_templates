# OxiCloud

[OxiCloud](https://atalayalabs.github.io/OxiCloud/) is a self-hosted cloud storage platforloads and can act as a DAV server.

## Setup

- Generate secrets/passwords with [`./generate-secrets.sh`](./generate-secrets.sh)
- Copy [example `.env` file](./.env.example) to `.env`
  - Set `OXICLOUD_IMG_TAG` to the [latest Oxicloud version](https://github.com/AtalayaLabs/OxiCloud/releases)
  - Set `POSTGRES_IMG_TAG` to the latest [postgres image](https://hub.docker.com/_/postgres/tags?name=-alpine). Find the latest version with `-alpine#.##`
  - Copy the `POSTGERS_PASSWORD` value from the secret generation script into the env var
  - Set your `OXICLOUD_BASE_URL`
    - `http[s]://[ip-or-fqdn][:optional-port]`
  - If exposing Oxicloud behind a reverse proxy, set `OXICLOUD_COOKIE_SECURE=true`
  - Copy the `OXICLOUD_STORAGE_ENCRYPTION_KEY` from the secrets generation script into the env var
  - Optionally, configure SMTP settings
- Bring the stack up with `docker compose up -d`
- Navigate to the URL you set in `OXICLOUD_BASE_URL` and setup an admin account

## DAV

Oxicloud exposes DAV servers at `/webdav/` (for files), `/carddav/` (for contacts), and `/caldav/` (for calendars). You must use an app password (created in your user's settings); the server will not accept your user's login password.

For example, use your file manager to browse to `https://oxicloud.your-domain.com/webdav/`, then login with your username and an app password.
