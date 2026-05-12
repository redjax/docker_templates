# Apprise

[Apprise](https://appriseit.com) is a push notification server with many integrations & clients.

## Setup

- Copy `.env.example` -> `.env`
  - You can generally run with the defaults, but you may want to update:
    - `APPRISE_WEBUI_PORT`
    - `APPRISE_API_HOST`
    - `APPRISE_STATEFUL_MODE`
    - `APPRISE_ATTACH_SIZE`
- Create config files
  - Copy `config/examples/example.apprise.yml` to `config/apprise.yml`
  - Copy or create any service-specific config files, i.e. [`gotify.yml`](./config/examples/example.gotify.yml)
- Run `docker compose up -d`

### Configuring Apprise notification servers

The `config/apprise.yml` file can source from other YAML configs. This allows for creating service-specific configuration files, like `config/ntfy.yml` and `config/gotify.yml`.

With this architecture, you can add multipl Ntfy topics/Gotify apps, and 'source' them in the `apprise.yml` file.

See one of the [example configs](./config/examples/) for syntax.
