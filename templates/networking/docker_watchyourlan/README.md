# WatchYourLAN

[WatchYourLAN](https://github.com/aceberg/WatchYourLAN) is a lightweight network IP scanner. It helps spot new devices on your network.

## Usage

- Copy the [example `.env` file](./.env.example) to `.env`
  - Set the `TZ` variable to your timezone
- Run `docker compose up -d`

The `compose.yml` stack only runs the `watchyourlan` container. To add other services like InfluxDB or Grafana, call the [overlay](./overlays/) like:

```shell
docker compose -f compose.yml -f overlays/influxdb.yml up -d
```

For InfluxDB, after starting the stack with `-f overlays/influxdb.yml`, navigate to `http://your-ip-or-fqdn:8086` and log into InfluxDB (default login: `admin`/`influxAdmin`), open the `watchyourlan` bucket, and go to "API Tokens" to generate a token for WatchYourLAN.

Back in the WatchYourLAN UI, open the config and fill in the details under "InfluxDB2 config." For address, if the container is on the same host and network as the `watchyourlan` container, you can use `influxdb:8086`.

Paste your token into the "Token" input. For "Org" and "Bucket," use the values set in `INFLUXDB_INIT_ORG` and `INFLUXDB_INIT_BUCKET` in your [`.env` file](.env.example) (default for both can be `watchyourlan`).
