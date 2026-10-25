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

