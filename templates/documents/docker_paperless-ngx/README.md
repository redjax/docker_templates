# Paperless-ng in Docker

My personal docker-compose for paperless-ng. Clone to machine, run inital-setup.sh, and start storing docs.

## Initial Setup

* Run `initial-setup.sh`
  * Copies example docker-compose.yml, .env, and docker-compose.env to live version
  * Generates a secret key and writes it to the file `secret_key` in the paperless-ng repository
    * Copy this key and paste it into the `PAPERLESS_SECRET_KEY` variable in docker-compose.env
  * Runs the initial createsuperuser command, where you'll create an admin account
* Manually edit .env and docker-compose.env files, where you'll set variable values like the port Paperless runs on, database password, etc

## Backup

There are 2 backup scripts included, `backup-db.sh` and `backup-documents.sh`. Each script takes flags (run the script without any flags to see available options). The restore feature isn't working (yet).

Example: backup database

`$> ./backup-db.sh -b`

This dumps the database file to `./backup/db/paperless_db_dump.sql`

## Upgrade Postgres Database

As a Postgres image reaches EOL, you will need to backup your current data, bump the Postgres version, restore your data, and possibly apply some manual fixes. This guide outlines the general steps you will take, but make sure you check Paperless docs before each database upgrade to see if there are any version-specific instructions you need to follow.

> [!NOTE]
> The instructions below were used to upgrade from Postgres 13 to 16.

- Bring the stack down but leave the database running, i.e.: `docker compose stop webserver broker gotenberg tika`
- Create a Postgresql backup: `docker exec -t paperless-db pg_dumpall -c -U paperless > paperless-backup.sql`
- Backup Paperless files (note: assumes you're using a host volume mount at `./data`
  - `tar czvf path/to/paperless-media-backup.tar.gz data/paperless/media`
  - `tar czvf path/to/paperless-data-backup.tar.gz data/paperless/data`
- Stop everything: `docker compose down`
- Preserve old cluster:
  - `mv data/postgres/data data/postgres/data-pg13`
    - If you are upgrading from a different version than 13, use that version number instead.
  - `mkdir -p data/postgres/data`
- Set the new image tag in the `compose.yml`, i.e. `image: postgres:16` (or whatever new version besides 16 you're upgrading to)
- Start only the Postgres container (give it a few seconds to start before running additional commands): `docker compose up -d db`
- Restore the database: `cat path/to/paperless-backup.sql | docker exec -i paperless-db psql -U paperless`
- Restart the full stack with `docker compose up -d`
- Confirm you see your tables with `docker exec -it paperless-db psql -U paperless -c "\l"`
- Check logs to make sure the container runs successfully: `docker logs paperless-server --tail=50`

If you run into authentication errors after upgrading, try to fix it with the following steps:

- Start a psql prompt with `docker exec -it paperless-db psql -U paperless`
- Attempt to reset the password with: `ALTER ROLE paperless WITH PASSWORD 'paperless';`
  - Quit the prompt with `\q`
- Restart the stack with `docker compose up -d --force-recreate`

