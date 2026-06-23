# Crow CI

[Crow CI](crowci.dev) is a CI/CD application forked from [Woodpecker](https://woodpecker-ci.org). It is fully container based and has additional features compared to Woodpecker.

## Setup

- Copy [example `.env` file](./.env.example) to `.env` and edit
  - Generate a `CROW_AGENT_SECRET` with [`./scripts/generate-agent-secret.sh`](./scripts/generate-agent-secret.sh).
  - Set the URL you will access Crow's webUI at in `CROW_SERVER_HOST`. Can be an IP address or FQDN:
    - `https://crow.example.com`
    - `192.168.1.xxx:8000`
  - Set the URL to your Forgejo instance in `CROW_FORGEJO_URL`. Can be an IP address or FQDN:
    - `https://forgejo.example.com`
    - `192.168.1.xxx:3000`
- In Forgejo, create an application by going to your settings, then "Application" (you might need to scroll to the bottom). See the [Forgejo OAuth2 section](#forgejo-oauth2) for more details.
  - For the redirect URI + `/authorize`, use your Crow CI URL, i.e. `https://crow.example.com/authorize` or `http://192.168.1.xx:8000/authorize`
  - Paste the client ID in `CROW_FORGEJO_CLIENT`
  - Paste the secret in `CROW_FORGEJO_SECRET`
- Generate an API token with the level of access your pipeline will need.
  - Forgejo will prompt you if you try to give it permissions it can't have
- Run `docker compose up -d`

### Forgejo OAuth2

After enabling OAuth2 in Forgejo by setting the env var `FORGEJO__oauth2__ENABLED=true`, you will find OAuth2 application settings available in the Forgejo UI, under `Settings -> Applications -> Authorized OAuth2 applications`.

Create a new app for Crow CI. For the "Redirect URIs" section, use your domain with `/authorize` at the end, i.e. `https://crow.example.com/authorize`.

Edit your [`.env` file](./.env.example), setting the `CROW_FORGEJO_CLIENT=<Forgejo OAuth2 client ID>` and `CROW_FORGEJO_SECRET=<Forgejo OAuth2 client secret>` env vars with the client ID and secret you created in Forgejo.
