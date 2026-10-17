# Arcane

[Arcane](https://getarcane.app/) is a Docker management suite. It can monitor and update Docker containers running on remote machines.

## Setup

- Copy the [example `.env` file](./.env.example) to `.env`
  - Set your timezone in `TZ`
  - Optionally change the user the container runs as by editing `PUID`/`PGID`
- Generate an an app secret with [`./generate_secrets.sh`](./generate_secrets.sh)
  - Copy the value into the `.env` file
- Run `docker compose up -d`

You can open the Arcane dashboard by navigating to `http(s)://your-ip-or-hostname:3552`. The default admin login is:

| Username | Password       |
| -------- | -------------- |
| `arcane` | `arcane-admin` |

## Authentik OIDC Auth

You can use Authentik to provide authentication to Arcane. In the Authentik admin panel, create a new provider named "Arcane" with the default authorization flow. Choose "Confidential" for the client type, and copy the client ID and secret. Save these in a password manager somewhere, you'll need them to set up the authentication redirect in Arcane.

Paste your Arcane's redirect URI. You can find this in the Arcane webUI by going to Settings > Authentication, toggling OIDC Authentication on, and clicking "Show configuration" beneath the toggle, then scrolling all the way to the bottom of the page and copying the "Redirect URI Configuration."

In Arcane's webUI, navigate to Settings > Authentication and toggle "OIDC Authentication" on. Click the "Show configuration" dropdown beneath the toggle. Paste the client ID and secret from Authentik in the form fields.

You can find the "Issuer URL" value in Authentik; after saving the provider, click it to open its configuration and note the "OpenID Configuration Issuer" value. You can also get this value by running the following command, replacing `$AUTHENTIK_URL` with your own domain:

```shell
curl -fsS \
  https://$AUTHENTIK_URL/application/o/arcane/.well-known/openid-configuration \
  | jq '{issuer, authorization_endpoint, token_endpoint, jwks_uri}'
```

Paste the `issuer` value from the cURL command above into "Issuer URL." Scroll back up to the top of the page and hit the Save button, then log out. You should now see "Authentik" as an option under "Or continue with."

## Troubleshooting

### Reset admin password

Temporarily set `ALLOW_CLI_PASSWORD_RESE=true` in the `.env` file. Restart the stack, then run:

```shell
docker compose exec arcane ./arcane admin reset-password --username arcane
```

If you're using the [`caddy.yml` layer](./overlays/caddy.yml), run this instead:

```shell
docker compose -f compose.yml -f overlays/caddy.yml \
  exec arcane ./arcane admin reset-password --username arcane
```

This will prompt you to set a new password for the `admin` user.
