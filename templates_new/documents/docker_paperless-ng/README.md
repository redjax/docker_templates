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
