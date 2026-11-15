# OpenGist

[OpenGist](https://opengist.io) is a self-hosted pastebin alternative to Github Gist/Gitlab Snippets.

## Quickstart

Run this if you want to just test Opengist before committing to running it in a permanent way, or if you are happy with the defaults:

```shell
docker run --name opengist -p 6157:6157 -v "$HOME/.opengist:/opengist" ghcr.io/thomiceli/opengist:1
```

## OAuth2 Authentication

### Authentik

- In Authentik:
  - Go to Applications -> Applications and click Create
  - Name the application "Opengist" and click Next
  - Select OAuth2/OpenID Provider and click Next
  - Set an authorization flow
  - Save the client ID and secret to a password manager
  - In "Redirect URIs/Origins (RegEx)," paste the following URL, replacing `$OPENGIST_ADDRESS` with your Opengist URL:
    - `https://$OPENGIST_ADDRESS/oauth/openid-connect/callback`
  - Add user/group/policy bindings, or leave them empty and press Next, then "Create Application"

- In your `.env` file:
  - Paste your client ID in `OPENGIST_OIDC_CLIENT_KEY`
  - Paste your client secret in `OPENGIST_OIDC_CLIENT_SECRET`
  - Set `OPENGIST_OIDC_DISCOVERY_URL` to the following, replacing `$AUTHENTIK_ADDRESS` with the FQDN or IP you use to reach Authentik:
    - `https://$AUTHENTIK_ADDRESS/application/o/opengist/.well-known/openid-configuration`

> [!NOTE]
> If you have disabled sign-ups, you can create an invite link and authenticate with that. Sign in as an admin user, to to Settings > Invitations, and create a new invitation. Sign out of Opengist and navigate to the invitation URL, then log in with Authentik.

## Serve Behind Caddy

When hosting OpenGist publicly, it's a good idea to proxy the container behind
Caddy or another server.

Create a new directory on the host, i.e. `~/docker_caddy`, and add the following
files:

- `compose.yml`

  ```yaml
  ---
  name: caddy

  volumes:
    data: {}
    config: {}

  services:
    caddy:
      image: caddy:${CADDY_IMG_TAG:-2}
      restart: unless-stopped
      network_mode: host

      environment:
        DOMAIN: ${DOMAIN:-localhost}
        ACME_EMAIL: ${ACME_EMAIL:-admin@localhost}
        OPENGIST_DOMAIN: ${OPENGIST_DOMAIN:-${DOMAIN:-localhost}}
        OPENGIST_UPSTREAM: ${OPENGIST_UPSTREAM:-127.0.0.1:6157}

      volumes:
        - ${CADDYFILE:-./Caddyfile}:/etc/caddy/Caddyfile:ro
        - ${CADDY_DATA_DIR:-data}:/data
        - ${CADDY_CONFIG_DIR:-config}:/config
  ```

- `Caddyfile`:

  ```plaintext
  {
    email {$ACME_EMAIL}
  }

  {$OPENGIST_DOMAIN} {
    log
    reverse_proxy {$OPENGIST_UPSTREAM} {
        header_up X-Real-IP {remote_host}
        header_up X-Http-Version {http.request.proto}
        header_up X-TLS-SNI-Name {tls_server_name}
      }
  }
  ```

- Add a `.env` file using the values relevant to your configuration:

  ```plaintext
  ## Default: 2
  CADDY_IMG_TAG=

  ## Default: localhost
  #  Use your domain with no protocol, i.e. my-git-domain.com
  DOMAIN=my-git-domain.com
  ## Default: admin@localhost
  ACME_EMAIL=address@example.com

  ## Default: (none/empty)
  #  Example: gist.example.com
  OPENGIST_DOMAIN=gist.my-git-domain.com
  ## Default: 127.0.0.1:6157
  #  When using Anubis, proxy to the Anubis port, i.e.
  #  127.0.0.1:8923
  OPENGIST_UPSTREAM=
  ```

When using Caddy, you should only bind OpenGist's ports to `127.0.0.1:<port>`. This forces traffic through the Caddy proxy and prevents exposing the port directly.

## Protect Site with Anubis

This stack includes an optional layer for [Anubis](https://anubis.techaro.lol/). You can protect your site from some automated scans/interactions (i.e. LLM agents and other bots) by running the stack with [`-f overlay/anubis.yml`](./overlays/anubis.yml), i.e.:

```shell
docker compose -f compose.yml -f overlays/anubis.yml up -d
```

First, edit your `.env` file. At minimum, you need to set a value for `ANUBIS_SIGNING_KEY`, which you can generate with `openssl rand -hex32`.

Next, update your [Caddy config's](#serve-behind-caddy) `.env` file; set `OPENGIST_UPSTREAM=127.0.0.1:8923` (Anubis's port). When a request is made to your OpenGist instance, it hits Caddy, then Anubis, where a challenge must be passed to get to your site.

Path filters in the `overlays/anubis.yml` control which requests are challenged. This allows for Git HTTPS and SSH traffic to continue working.

