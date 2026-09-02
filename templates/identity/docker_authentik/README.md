# Authentik <!-- omit in toc -->

[Authentik](https://goauthentik.io/) is an open source identity provider.

## Table of Contents <!-- omit in toc -->

- [Setup](#setup)
- [Links](#links)

## Setup

- Copy the [example `.env` file](./.env.example) to `.env`
  - Edit values to your liking, i.e. changing HTTP/HTTPS ports or volume mounts
  - For any `*_IMG_TAG` variable, make sure to check the most recent tag using the link above the env var.
- Generate secrets with [`./generate-secrets.sh`](./generate-secrets.sh)
  - Copy the values the script outputs into your `.env`
- Run `docker compose up -d`

Authentik will be available at your server's IP on the port you set in `AUTHENTIK_HTTP_PORT`, or via HTTPS using the `AUTHENTIK_HTTPS_PORT`. For example: `http(s)://<ip-or-hostname>:$AUTHENTIK_PORT`.

The first time you load Authentik, you will be guided through setting up an admin user.

## Links

- [Authentik home](https://goauthentik.io)
- [Authentik Github](https://github.com/goauthentik/authentik)

