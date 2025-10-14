# Hoppscotch

Self-hosted API development ecosystem.

## Setup

- Run [`./scripts/generate_hoppscotch_secrets.sh`](./scripts/generate_hoppscotch_secrets.sh) to generate secret values.
- Copy the [example Hoppscotch env file](./example.hoppscotch.env) to `hoppscotch.env`
  - Update the database URL.
    - If you're using a different `DB_PASSWORD` value in the [stack's `.env` file](./.env.example), make sure you set it here.
    - If you're using an external Postgres host, set the database URL for the external server.
  - Paste the values of `JWT_SECRET`, `SESSION_SECRET`, and `DATA_ENCRYPTION_KEY` into their corresponding spots in the `hoppscotch.env` file
  - If serving outside of your localhost, update `REDIRECT_URL`
    - Accepts values like `http://192.168.1.100:3000`, `https://hoppscotch.example.com`, etc.
    - Update the `WHITELISTED_ORIGINS` list with your IP/domain.
      - `http://localhost:3170` -> `http(s)://<ip-or-fqdn>:3170`
      - `http://localhost:3000` -> `http(s)://<ip-or-fqdn>:3000`
      - `http://localhost:3100` -> `http(s)://<ip-or-fqdn>:3100`
      - `app://localhost_3200` -> `http(s)://<ip-or-fqdn>_3200`
  - To enable workspace saving, you must [enable an authentication provider](#authentication-providers).

> [!WARNING]
> When running Hoppscotch for the first time, use th [`first_run.sh` script](./scripts/first_run.sh).
> This script does database migrations to prepare the database, then brings the stack down.

### Authentication providers

To [enable OAuth](https://docs.hoppscotch.io/guides/articles/self-host-hoppscotch-on-your-own-servers#3-oauth-configuration) (for saving encrypted workspaces to a backend), edit the [Hoppscotch env file](./example.hoppscotch.env) and update the following sections to enable 1 or more OAuth providers:

```plaintext
# Google Auth Config
GOOGLE_CLIENT_ID=************************************************
GOOGLE_CLIENT_SECRET=************************************************
GOOGLE_CALLBACK_URL=http://localhost:3170/v1/auth/google/callback
GOOGLE_SCOPE=email,profile

# Github Auth Config
GITHUB_CLIENT_ID=************************************************
GITHUB_CLIENT_SECRET=************************************************
GITHUB_CALLBACK_URL=http://localhost:3170/v1/auth/github/callback
GITHUB_SCOPE=user:email

# Microsoft Auth Config
MICROSOFT_CLIENT_ID=************************************************
MICROSOFT_CLIENT_SECRET=************************************************
MICROSOFT_CALLBACK_URL=http://localhost:3170/v1/auth/microsoft/callback
MICROSOFT_SCOPE=user.read
MICROSOFT_TENANT=common
```

To setup Github OAuth, go to [Github developer settings](https://github.com/settings/apps), Click ['OAuth Apps' option](https://github.com/settings/developers) in the sidebar, and click "New  OAuth app."

Set the callback URL to your server's IP with `/v1/auth/github/callback` at the end. For example:

- Localhost: `http://localhost:3170/v1/auth/github/callback`
- LAN IP 192.168.1.150: `http://192.168.1.150:3170/v1/auth/github/callback`
- Domain: `https://hoppscotch.example.com/v1/auth/github/callback`

## Links

- [Hoppscotch Github](https://github.com/hoppscotch/hoppscotch)
- [Hoppscotch home](https://hoppscotch.io)
- [Hoppscotch docs](https://docs.hoppscotch.io)
  - [Hoppscotch Docker Compose setup docs](https://docs.hoppscotch.io/documentation/self-host/community-edition/install-and-build)

