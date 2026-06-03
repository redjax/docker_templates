# Miniflux

[Miniflux](https://miniflux.app) is a minimalist & opinionated feed reader with a powerful API.

## Usage

## Backup & Restore

The included [`backup-miniflux-db.sh` script](./scripts/backup-miniflux-db.sh) creates a backup/dump of the Postgres database. This operation assumes you're using the [Postgres overlay](./overlays/postgres.yml); if your database is running on another host you might need to modify the commands. You can schedule it with cron to take regular backups.

Run the script with `-h`/`--help` to see usage instructions.

The [`restore-miniflux-db.sh` script](./scripts/restore-miniflux-db.sh) restores an existing database backup. Run it with `-h`/`--help` to see usage.

The [`clean-miniflux-backups.sh` script](./scripts/clean-miniflux-backups.sh) can cleanup old backups. Run it with `--retain <N>` to ensure at least `N` copy/ies are retained.

### RSSHub

The [`rsshub.yml` overlay](./overlays/rsshub.yml) adds [RSSHub support](https://rsshub.app), allowing you to create feeds from one of many ["routes"](https://docs.rsshub.app/routes/). Start the RSSHub container with miniflux like:

```shell
docker compose -f compose.yml -f overlays/rsshub.yml up -d
```

Navigate to `http(s)://<your-server-or-ip>:1200` to see the running server. To use it, form a URL based on one of the available [routes](https://docs.rsshub.app/routes).

Examples:

- A [Github release](https://docs.rsshub.app/routes/github): `http://your-server:1200/github/release/hashicorp/terraform`
- A [Bluesky profile](https://docs.rsshub.app/routes/bsky): `http://your-server:1200/bsky/profile/bsky.app`
- An [APNews feed](https://docs.rsshub.app/routes/apnews): `http://your-server:1200/apnews/topics/apf-topnews`
- [LinkedIn job postings](https://docs.rsshub.app/routes/linkedin): `http://your-server:1200/linkedin/jobs/C-P/1/software engineer`
- Top weekly [dev.to posts](https://docs.rsshub.app/routes/dev.to): `http://your-server:1200/dev.to/top/week`
- A [specific Steam game](https://docs.rsshub.app/routes/steam): `http://your-server:1200/news/958260/english`
- The [Python release feed](https://docs.rsshub.app/routes/python): `http://your-server:1200/python/release`
- A [Discord channel](https://docs.rsshub.app/routes/discord): `http://your-server:1200/discord/channel/950465850056536084`

## FiveFilters

The [`fivefilters.yml` overlay](./overlays/fivefilters.yml) provides text extraction and adblocking via [FiveFilters](https://www.fivefilters.org). This is provided through the [unofficial `heussd/fivefilters-full-text-rss-docker` container](https://github.com/heussd/fivefilters-full-text-rss-docker).

You can run the overlay with the Miniflux container using:

```shell
docker comose -f compose.yml -f overlays/fivefilters.yml
```

Then in Miniflux, add a feed like: `http://fivefilters/makefulltextfeed.php?url=https://example.com/feed.xml`

## Links

- [Miniflux home](https://miniflux.app)
- [Miniflux Github](https://github.com/miniflux/v2)
- [Miniflux documentation](https://miniflux.app/docs/index.html)
