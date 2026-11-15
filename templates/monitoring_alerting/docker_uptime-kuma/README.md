# Uptime Kuma

[Uptime Kuma](https://uptimekuma.co/) is a self-hosted monitoring tool. It can monitor many protocols, from HTTP(S), to DNS records, Docker containers, databases, and ICMP, and can integrate with [many different notification services](https://github.com/louislam/uptime-kuma/tree/master/src/components/notifications) to alert you when a site is down or an unexpected response occurs.

[Uptime Kuma on Github](https://github.com/louislam/uptime-kuma).

## Setup

- Copy the [example `.env` file](./.env.example) to `.env`
  - Change any defaults as desired, but the stack should run fine with no modifications
- Run `docker compose up -d`

The [`run_uptime_kuma.sh` script](./run_uptime_kuma.sh) runs Uptime Kuma with `docker run` instead of `docker compose`, it's meant for quick prototyping on a new host.
