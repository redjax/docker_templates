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

With this architecture, you can add multiple Ntfy topics/Gotify apps, and 'source' them in the `apprise.yml` file.

See one of the [example configs](./config/examples/) for syntax. Also see the [Apprise URL builder](https://appriseit.com/url-builder/) for the syntax Apprise needs.

## Sending notifications

In the Apprise webUI (port :8000), open "Configuration List." Find the configuration for the service you want to use, i.e. Gotify. You will see a `CONFIG ID` at the top of the page. This becomes the URL to that channel in Apprise.

For example, to send a message on the Gotify channel:

```shell
curl -X POST \
  -F "body=Test Message" \
  -F "tags=all" \
  http://apprise.mydomain.com/notify/gotify
```

The configuration page will have more examples if you scroll down.

## Protect webUI with reverse proxy

If using a reverse proxy that supports securing routes behind authentication (i.e. Pangolin, Netbird, etc), you can protect the webUI with login, while still exposing important routes calling services will need.

If your proxy supports bypassing auth on specific paths, add the following:

- `status`
- `api/*`

