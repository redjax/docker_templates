# Netbird <!-- omit in toc -->

[Netbird](https://netbird.io) is a Wireguard-based overlay network with zero trust network access (similar to Tailscale).

## Requirements

- Docker
- A domain name
- DNS `A` record pointing your domain, i.e. `vpn.example.com`, to your server/VPS

## Setup

The initial setup for Netbird is a little bit complicated, but I wrote some scripts that make the process easier.

The [template files](./templates) were created by running the [`bootstrap-netbird.sh` script](./scripts/bootstrap-netbird.sh).
 
This script downloads and runs the [official Netbird convenience script](https://docs.netbird.io/selfhosted/selfhosted-quickstart#installation-script) to create the initial Docker Compose stack in the `/tmp/netbird-bootstrap` directory.

I then copied the files here and replaced values like the auth/store secret and domain with environment variables for substitution using the [`render-config.sh` script](./scripts/render-config.sh).

You are free to repeat this process to setup Netbird, but the template files here should be sufficient.

### Steps

- Copy the [example `.env`](./.env.example) to `.env`
  - Optionally, change any defaults for the container stack
- If you're using `direnv`, create a file `.envrc.local` and copy the commented section at the bottom of [`.envrc`](./.envrc) into it to configure the local environment.
- Run the [`generate-secrets.sh` script](./scripts/generate-secrets.sh) to generate a Netbird auth secret and store encryption key.
  - The script also generates a Postgres admin password, but you can ignore this unless you're using the [`postgres.yml` overlay](./postgres.yml).
- Export the initial secrets to environment variables, example:

  ```shell
  export NETBIRD_DOMAIN="vpn.example.com"
  export NETBIRD_AUTH_SECRET=<secret from generate-secrets.sh>
  export NETBIRD_STORE_ENCRYPTION_KEY=<secret from generate-secrets.sh>
  ```

  - You can also run the following commands manually to generate the secrets:
    - `NETBIRD_AUTH_SECRET`: `openssl rand -hex 32 | tr -d '[:space:]'`
    - `NETBIRD_STORE_ENCRYPTION_SECRET_KEY`: `openssl rand 32 | base64 | tr -d '\n'`
- Export a valid email address for Letsencrypt with Caddy:

  ```shell
  export CADDY_LETSENCRYPT_EMAIL=example@email.com
  ```
- Run `./scripts/render-config.sh` to generate the initial configuration files
- Run `docker compose up -d` to start the containers

### Initial webUI setup

After bringing the compose stack up, navigate to `https://vpn.yourdomain.com`. You should be redirected to the initial account creation page. Setup an admin user with a strong password (you can create a separate user account for yourself later).

Follow the setup instructions to install the app, or skip them and do it later. It is recommended you enable MFA in the settings, then log out and back in to trigger the MFA setup.
