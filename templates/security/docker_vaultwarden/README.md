# Vaultwarden

[Vaultwarden](https://github.com/dani-garcia/vaultwarden) is an open source implementation of the Bitwarden server.

## Description

Self host your own Bitwarden instance.

This stack includes the following backup containers:

- [querylab/lazywarden](https://github.com/querylab/lazywarden): Backup your vault to Bitwarden's servers.
- [Bruceforce/vaultwarden-backup](https://github.com/Bruceforce/vaultwarden-backup): Take local backups of Vaultwarden's database, attachments, & configs.

## Setup

- Copy env files
  - `cp .env.example .env`
  - `cp lazywarden.env.example lazywarden.env`
    - `lazywarden` requires some secrets to access your Bitwarden account & backup the Vaultwarden vault.
    - Edit the variables at the top.
  - `cp vaultwarden-backup.env.example vaultwarden-backup.env`
    - You can run with the default settings, which create a backup every night at 11:59PM, retaining 90 backups, with no encryption.

### Lazywarden - backup to Bitwarden's servers

The `lazywarden` container can backup your Vaultwarden vault to Bitwarden's servers. This ensures if your server ever goes down or your data is corrupted, you can still log into your Bitwarden account to export your vault and start over.

To enable this, you need the following from Bitwarden:

- [A Bitwarden account](https://bitwarden.com/go/start-free/)
- [A personal API key for CLI authentication](https://bitwarden.com/help/personal-api-key/)

The container runs on a schedule (default: every night at 11:59PM), backing up your Vaultwarden data to Bitwarden's servers via API.

## Usage

After [creating your `.env` files](#setup), run `docker compose up -d`. Visit the webUI at `http://your-server:8205` (or whatever value you set for `VW_WEBUI_PORT` in the [`.env file`](./.env.example)).

### CLI

To use Vaultwarden in the terminal, install the [Bitwarden CLI app](https://bitwarden.com/help/cli), then use [the `bw config server` command to set your Vaultwarden server](https://bitwarden.com/help/cli/#config).

Example:

```shell
bw config server https://vault.yourdomain.com
```

You can log into your server with `bw login --apikey`, which will prompt you for your client ID and secret. After authenticating, you can unlock your vault with `bw unlock`.

Note that you can also set the following environment variables to pre-authenticate:

```text
BW_CLIENTID=<your Vaultwarden API client ID>
BW_CLIENTSECRET=<your Vaultwarden API client secret>
```

If your Vaultwarden instance supports SSO, you can also authenticate with `bw login --sso`.

## Links

- [Lazywarden Setup Guide](https://www.lazywarden.com/Configuration/secrets)

