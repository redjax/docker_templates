# Woodpecker CI

Self-hosted [Woodpecker CI](https://woodpecker-ci.org) server & agent.

## Setup

### Network

Run the [`create_ci_network.sh` script](./scripts/create_ci_network.sh) to create a `woodpecker_net` "external" Docker network for the server & agent to connect to.

### Forgejo OAuth2

After enabling OAuth2 in Forgejo by setting the env var `FORGEJO__oauth2__ENABLED=true`, you will find OAuth2 application settings available in the Forgejo UI, under `Settings -> Applications -> Authorized OAuth2 applications`.

Create a new app for Woodpecker. For the "Redirect URIs" section, use your domain with `/authorize` at the end, i.e. `https://ci.example.com/authorize`.

Edit your [`.env` file](./.env.example), setting the `WOODPECKER_FORGEJO_CLIENT=<Forgejo OAuth2 client ID>` and `WOODPECKER_FORGEJO_SECRET=<Forgejo OAuth2 client secret>` env vars with the client ID and secret you created in Forgejo.

> [!WARNING]
> If you get an error after attempting to sign in with Forgejo that says "The registration is closed," this is because the `WOODPECKER_OPEN` env variable is set to `false`.
>
> You must set this to `true` to enable registrations with the OAuth2 app.
