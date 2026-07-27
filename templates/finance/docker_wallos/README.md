# Wallos

[Wallos](https://github.com/ellite/Wallos) is a self-hosted subscription tracker

## Setup

- Copy [example `.env`](./.env.example) to `.env` and edit it
  - Optionally, change the default port from `8282`.
    - If you change this, replace any other vars that use port `8282` with the port you use.
  - If you're using a reverse proxy, set the `WALLOS_APP_URL`, i.e. `https://wallos.mydomain.com`.
  - If you want to store data on your host instead of in a Docker volume, set `WALLOS_DB_DIR` and/or `WALLOS_LOGOS_DIR`, i.e. `WALLOS_DB_DIR=./data/db`.
  - If you have a [fixer.io API key](https://fixer.io), put it in `WALLOS_FIXER_API_KEY`.
    - This is used for currency conversions.
  - If you have OIDC setup/available, i.e. Google SSO or Authentik, paste the client ID and secret and issuer user values.
- Run `docker compose up -d`
- Access your app at one of the URLs below:
  - Default: `http://<your-ip-or-hostname>:8282`
  - If you set a `WALLOS_APP_URL`, access Wallos at that URL.
