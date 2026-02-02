# Netbird <!-- omit in toc -->

[Netbird](https://netbird.io) is a Wireguard-based overlay network with zero trust network access (similar to Tailscale).

## Table of Contents <!-- omit in toc -->

- [Setup](#setup)
  - [LAN setup](#lan-setup)
    - [Zitadel](#zitadel)
    - [Netbird](#netbird)
  - [VPS Setup](#vps-setup)
- [Links](#links)

## Setup

Copy the following files in preparation:

- [`.env.example`](./.env.example) -> `.env`
- [`env_files/example.netbird.env`](./env_files/example.netbird.env) -> `env_files/netbird.env`
- [`config/example.managment.json](./config/example.managment.json) -> `config/netbird/management.json`

Follow the sections below, depending on the type of setup you're doing. You can setup Netbird on [a machine on your LAN](#lan-setup) or [in a VPS](#vps-setup)

The main differences between the 2 types of setup are the URLs you will use. You will need to set up Zitadel before starting Netbird configuration.

In both cases, you will also need passwords and secret values. Use [ the `generate_secrets.sh` script](./generate_secrets.sh) to generate them. You will need to put these secrets in your `.env` and `./config/netbird/management.json` files, so make a note of them. Also advised to save these passwords in a password manager.

### LAN setup

#### Zitadel

Paste the Zitadel and Postgres secrets generated with [`generate_secrets.sh`](./generate_secrets.sh) into the `.env` file:

```shell
# .env
ZITADEL_ADMIN_PASSWORD=...
ZITADEL_MASTER_KEY=...
PG_PASSWORD=...
ZITADEL_DB_USER_PASS=...
```

Start the containers:

```shell
docker compose up -d postgres
docker compose up -d zitadel
```

Access the Zitadel UI (i.e. `http://<your-lan-ip>:8080`). Create an organization/project, and an OIDC client for Netbird. Note the `ClientID` and `ClientSecret`.

#### Netbird

### VPS Setup

## Links

- [Netbird docs](https://docs.netbird.io)
- [Zitadel docs](https://zitadel.com/docs)
  - [Docker Compose setup](https://zitadel.com/docs/self-hosting/deploy/compose)
