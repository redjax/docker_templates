# Woodpecker CI

Self-hosted [Woodpecker CI](https://woodpecker-ci.org) server & agent.

## Setup

- Copy [example `.env` file](./.env.example) to `.env` and edit
  - Generate a `WOODPECKER_AGENT_SECRET` with [`./scripts/gen_woodpecker_secret.sh`](./scripts/gen_woodpecker_secret.sh).
  - Set the URL you will access Woodpecker's webUI at in `WOODPECKER_URL`. Can be an IP address or FQDN:
    - `https://woodpecker.example.com`
    - `192.168.1.xxx:8000`
  - Set the URL to your Forgejo instance in `WOODPECKER_FORGEJO_URL`. Can be an IP address or FQDN:
    - `https://forgejo.example.com`
    - `192.168.1.xxx:3000`
- In Forgejo, create an application by going to your settings, then "Application" (you might need to scroll to the bottom). See the [Forgejo OAuth2 section](#forgejo-oauth2) for more details.
  - For the redirect URI + `/authorize`, use your Woodpecker URL, i.e. `https://woodpecker.example.com/authorize` or `http://192.168.1.xx:8000/authorize`
  - Paste the client ID in `WOODPECKER_FORGEJO_CLIENT`
  - Paste the secret in `WOODPECKER_FORGEJO_SECRET`
- Generate an API token with the level of access your pipeline will need.
  - Forgejo will prompt you if you try to give it permissions it can't have
- Run `docker compose up -d`

### Forgejo OAuth2

After enabling OAuth2 in Forgejo by setting the env var `FORGEJO__oauth2__ENABLED=true`, you will find OAuth2 application settings available in the Forgejo UI, under `Settings -> Applications -> Authorized OAuth2 applications`.

Create a new app for Woodpecker. For the "Redirect URIs" section, use your domain with `/authorize` at the end, i.e. `https://ci.example.com/authorize`.

Edit your [`.env` file](./.env.example), setting the `WOODPECKER_FORGEJO_CLIENT=<Forgejo OAuth2 client ID>` and `WOODPECKER_FORGEJO_SECRET=<Forgejo OAuth2 client secret>` env vars with the client ID and secret you created in Forgejo.

> [!WARNING]
> If you get an error after attempting to sign in with Forgejo that says "The registration is closed," this is because the `WOODPECKER_OPEN` env variable is set to `false`.
>
> You must set this to `true` to enable registrations with the OAuth2 app.
