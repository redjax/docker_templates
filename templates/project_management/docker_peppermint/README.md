# Peppermint

[Peppermint](https://github.com/Peppermint-Lab/peppermint) is an issues tracker/project management software akin to Jira.

## Setup

- Copy `.env.example` to `.env`
- Generate a secret for the app:
  - Run `head -c 32 /dev/urandom | base64`
  - Or, run the [`generate_peppermint_secret.sh` script](./generate_peppermint_secret.sh)
  - Paste the value in the `.env` file's `PEPPERMINT_SECRET` value
- Run `docker compose up -d`
- Navigate to `http://ip-or-fqdn:3000`
  - If you used a port other than `3000` for `PEPPERMINT_WEBUI_PORT`, use that port instead in the URL
- Log into the admin dashboard with the following credentials:
  - User: admin@admin.com
  - Password: 1234
