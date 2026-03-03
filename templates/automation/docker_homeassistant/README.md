# HomeAssistant

[HomeAssistant](https://www.home-assistant.io) is an open source home automation tool. The server is [self-hostable](https://github.com/home-assistant/core), and can [integrate with a huge number of services](https://www.home-assistant.io/integrations/?brands=featured). You can self-host instances of [node-red](https://nodered.org) and [n8n](https://n8n.io), too, and add even more integrations via those tools.

## Setup

If you're using local host mounts for data volumes, run [the setup script](./scripts/run-initial-setup.sh). Otherwise, copy the [example `.env.`](.env.example) to a `.env` and edit it to your liking, then run `docker compose up -d`.

If you want more functionality like `node-RED` or MQTT, you can add additional [layers](./overlays/) by using `-f`:

```shell
docker compose -f compose.yml -f overlays/mosquitto.yml -f overlays/nodered.yml -f overlays/hass-configurator.yml`.
```

## Links

- [Setup guide](https://pimylifeup.com/home-assistant-docker-compose)
