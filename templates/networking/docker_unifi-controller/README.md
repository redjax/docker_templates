# Unifi Controller <!-- omit in toc -->

The new version of the Unifi controller. [https://github.com/linuxserver/docker-unifi-network-application](https://github.com/linuxserver/docker-unifi-network-application).

## Table of Contents <!-- omit in toc -->

- [Setup](#setup)
- [Rsyslog](#rsyslog)
- [Backups](#backups)

## Setup

- Copy the [example `.env` file](./.env.example) to `.env`
  - Set your `TZ`
  - Optionally, set a host volume mount for the `UNIFI_CONFIG_DIR`, i.e. `UNIFI_CONFIG_DIR=./unifi/config`
  - Change the `MONGO_ROOT_PASSWORD` and `MONGO_PASS` values (set a secure password)

Bring the stack up with `docker compose up -d`, then navigate to whatever port you set for `UNIFI_WEBUI_PORT` (default: `:8443`): `https://hostname-or-ip:8443`

## Rsyslog

The [`rsyslog.yml` layer](./overlays/rsyslog.yml) adds an `rsyslog` collector and `logrotate` container to the running stack. In the Unifi Network Application's UI, you can send logs to the `rsyslog` container by going to Settings > CyberSecure > Traffic Logging, then set the "Activity Logging" to "SIEM Server." Use the IP address of the host running the network application, and whatever port you set for `SYSLOG_PORT`.

To run Unifi with `rsyslog`, add the `overlays/rsyslog.yml` layer to the `docker compose` command with `-f`:

```shell
docker compose -f compose.yml -f overlays/rsyslog.yml up -d
```

By default, logs in the `rsyslog` collector container are stored in `/var/log/all-remote.log`, with Unifi-specific logs filtering into a `/var/log/unifi.log`. You can read these logs using the [`read-syslog.sh` script](./scripts/read-syslog.sh), or by running:

```shell
docker compose exec -it rsyslog-collector tail -n 200 -f /var/log/all-remote.log
```

To read a different log file, pass it instead of `all-remote.log`. For example, to read the Unifi log:

```shell
docker compose exec -it rsyslog-collector tail -n 200 -f /var/log/unifi.log
```

## Backups

If you enable auto-backups in the Unifi Network Application, they will be stored in `/config/data/backup`. If you use a host volume mount for `UNIFI_CONFIG_DIR`, i.e. `UNIFI_CONFIG_DIR=./unifi/config`, you can just back that directory up with a Bash script running on a cron schedule.

If you are using the default Docker volume, use a command like:

```shell
docker compose cp network-application:/config/data/backup /path/on/host/backup
```
