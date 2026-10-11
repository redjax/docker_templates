# Uptime Cairn

[Uptime Cairn](https://github.com/webloomlabs/uptime-cairn) is an uptime monitoring service similar to Uptime Kuma (and in fact can import existing Uptime Kuma targets). It can also monitor cron jobs and APIs.

## Setup

- Copy the [example `.env` file](./.env.example) to `.env`
  - Cairn does not require much to run. You can run it on a different port, if you want.
- Navigate to `http(s)://your-ip-or-fqdn[:3000]`, where the `:3000` port is only required if using an IP address.
  - Create a user, i.e. `admin` or `yourusername`.
  - Cairn only has 1 user, you cannot and won't need to create additional users later.

## Import from Uptime Kuma

Cairn can import an Uptime Kuma `kuma.db` SQLite database. If you're running Uptime Kuma straight on your host, just copy and upload the `kuma.db` file (search the Uptime Kuma docs for the default path).

If you're running in Docker, copy the database out of the container:

```shell
docker cp uptime-kuma:/app/data/kuma.db ./kuma.db
```

Then upload it in the Cairn webUI by opening Settings > Import.

