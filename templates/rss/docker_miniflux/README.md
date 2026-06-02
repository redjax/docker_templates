# Miniflux

[Miniflux](https://miniflux.app) is a minimalist & opinionated feed reader with a powerful API.

## Usage

## Backup & Restore

The included [`backup-miniflux-db.sh` script](./scripts/backup-miniflux-db.sh) creates a backup/dump of the Postgres database. This operation assumes you're using the [Postgres overlay](./overlays/postgres.yml); if your database is running on another host you might need to modify the commands. You can schedule it with cron to take regular backups.

Run the script with `-h`/`--help` to see usage instructions.

The [`restore-miniflux-db.sh` script](./scripts/restore-miniflux-db.sh) restores an existing database backup. Run it with `-h`/`--help` to see usage.

The [`clean-miniflux-backups.sh` script](./scripts/clean-miniflux-backups.sh) can cleanup old backups. Run it with `--retain <N>` to ensure at least `N` copy/ies are retained.

## Links

- [Miniflux home](https://miniflux.app)
- [Miniflux Github](https://github.com/miniflux/v2)
- [Miniflux documentation](https://miniflux.app/docs/index.html)
