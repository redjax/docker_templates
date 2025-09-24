# Nextcloud

[Nextcloud](https://nextcloud.com) is a self-hostable cloud comparable to Google Drive or Microsoft Onedrive.

## Notes

There are [overlays](./overlays/) for this container. You can run Nextcloud with the [`lan-only.yml`](./overlays/lan-only.yml) if you are only serving the web UI on your local network, or [`proxied.yml`](./overlays/proxied.yml) if running behind a proxy like NGINX or Pangolin.

You can also add a [redis cache](./overlays/redis.yml) to speed up operations, and [Collabora](./overlays/collabora.yml) for collaboration tools, making it more like Google Drive.

To run Nextcloud with 1 or more overlays, you need to pass every compose file to the command with `-f path/to/compose-file.yml`.

**Run Nextcloud + LAN**

```bash
docker compose -f compose.yml -f overlays/lan-only.yml up -d
```

**Run Nextcloud + Proxy + Redis cache**

```bash
docker compose -f compose.yml -f overlays/proxied.yml -f overlays/redis.yml
```

**Run Nextcloud + Proxy + Redis cache + Collabora**

```bash
docker compose -f compose.yml -f overlays/proxied.yml -f overlays/redis.yml -f overlays/collabora.yml
```

> [!NOTE]
> When running any other Compose command, like `docker compose down` or `docker compose logs -f <container-name>`,
> you must pass the main `compose.yml` along with the overlay for the container(s) you want to operate on.
>
> For example, to get the logs for the Redis container, you would run:
> 
> `$> docker compose -f compose.yml -f overlays/redis.yml logs -f nextcloud-aio-redis`
