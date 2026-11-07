# Komodo

[Komodo](https://komo.do) is a build & deployment system.

## Setup

- Copy [example `.env` file](./.env.example) to `.env`.
  - Override any values you want.
  - If you're not using Caddy, you can ignore the `CADDY_*` variables.
- Run `docker compose up -d`

### Caddy

The stack includes a [Caddy layer](./overlays/caddy.yml) for self-signed SSL certificates. If you are running this behind another existing reverse proxy, you do not need to use this.

When running the stack locally and accessing it by IP address or local hostname, you can serve the site with SSL using the [Caddy layer](./overlays/caddy.yml). You will need to set the `KOMODO_TLS_NAMES` and `KOMODO_DEFAULT_SNI` environment variables in the `.env` file.

`KOMODO_TLS_NAMES` should be 1 or more addresses/hostnames you use to access the site, i.e. `KOMODO_TLS_NAMES=192.168.1.50`, `KOMODO_TLS_NAMES=192.168.1.50 komodo.home.arpa`, or `KOMODO_TLS_NAMES=komodo.example.com`.

`KOMODO_DEFAULT_SNI` should be the IP address or hostname you use to access the site. This is the server the SSL certificate will have. For example, `KOMODO_DEFAULT_SNI=192.168.1.50` or `KOMODO_DEFAULT_SNI=komodo.example.com`.

### Authentik OIDC Auth

Komodo supports OIDC loging with Authentik natively. In Authentik, create a new OAuth2/OpenID provider named "Komodo." Use "Confidential" for the client type, and save the Client ID/Secret in a password manager. Set the "Redirect URI" to your `KOMODO_HOST` value, followed by `/auth/oidc/callback`. Add the following values to your `.env`:

```plaintext
# Exact URL you use to access Komodo, including any nonstandard port.
KOMODO_HOST=https://YOUR_KOMODO_ADDRESS:PORT

KOMODO_OIDC_ENABLED=true
KOMODO_OIDC_PROVIDER=https://auth.example.com/application/o/komodo/
KOMODO_OIDC_CLIENT_ID=YOUR_AUTHENTIK_CLIENT_ID
KOMODO_OIDC_CLIENT_SECRET=YOUR_AUTHENTIK_CLIENT_SECRET
```
