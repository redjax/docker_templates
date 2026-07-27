# Davis

[Davis](https://github.com/tchapi/davis) is a modern & simple admin interface for Sabre/DAV.

## Instructions

- Copy the [example `.env` file](./.env.example) to `.env`
  - Change/set the following env vars:
    - `DB_ROOT_PASSWORD`: Set a strong password for root database user.
    - `DB_PASSWORD`: Set a strong password (different from the root password).
    - `ADMIN_PASSWORD`: Set the Davis admin user's password.
      - To change this password, just set a new value and restart the container.
    - Enable CalDAV, CardDAV, and/or WebDAV by setting the corresponding env vars to `true`
    - Set `APP_TIMEZONE` to your timezone.
    - Create an app secret by running [`generate-secrets.sh`](./generate-secrets.sh).
      - Copy the secret value into `APP_SECRET` in the `.env` file.
- Bring the stack up with `docker compose up -d`
- If this is the first time you're starting the containers on this machine, run the [`first-launch-migrations.sh`](./first-launch-migrations.sh) script to do database migrations.
  - This is only required on new/fresh setups.
- Access the admin UI at `http://ip-or-fqdn:9000`
  - If you set a `DAVIS_PORT` value to something other than `9000`, use that port instead.
- Access the DAV interface at `http://ip-or-fqdn:9000/dav`.

## Connecting to DAV

The DAV root for the server is at `https://davis.your-domain.com/dav`. You can use sub-paths to get to calDAV, cardDAV, and webDAV.

On iPhone, DAV is built in. You can add a calDAV or cardDAV account using the 'Mail' settings.

On Android, use the [Davx5 app](https://www.davx5.com/).

You can access individual DAV links using the URLs detailed below.

### CalDAV

You can access your calendars from the URL: `https://davis.your-domain.com/dav/calendars/<USERNAME>/<calendar-id>`. The default calendar is at `/dav/calendars/<USERNAME>/default/`.

### CardDAV

You can access your contacts from the URL: `https://davis.your-domain.com/dav/addressbooks/<USERNAME>/`. The default address book is at `/dav/addressbooks/<USERNAME>/default/`.

### WebDAV files

The URL for webDAV is `https://davis.your-domain.com/dav/home/<USERNAME>`. If you are mounting the path, for example in KDE Dolphin's file explorer, the URL should be: `webdavs://davis.your-domain.com/dav/home/<USERNAME>/`.

## Backups

If you are using host volume mounts, i.e. `./data/dav` and `./data/webdav`, simply back these directories up.

If you are using Docker volumes (the default), you can use the following commands.

To backup the Davis database volume:

```shell
docker run --rm \
  -v davis-sqlite_davis_data:/data:ro \
  -v "$PWD/backups":/backup \
  alpine \
  tar czf /backup/davis_data_$(date +%F).tar.gz -C /data .
```

This will create a backup of the Davis data volume to `./backups`.

To backup the Davis webDAV volume (if you set `WEBDAV_ENABLED=true`):

```shell
docker run --rm \
  -v davis-sqlite_davis_webdav:/data:ro \
  -v "$PWD/backups":/backup \
  alpine \
  tar czf /backup/davis_webdav_$(date +%F).tar.gz -C /data .
```

### Restoring from backup

Before running Davis, restore the database with:

```shell
docker run --rm \
  -v davis-sqlite_davis_data:/data \
  -v "$PWD/backups":/backup \
  alpine \
  sh -c "rm -rf /data/* && tar xzf /backup/davis_data_YYYY-mm-dd.tar.gz -C /data"
```

And restore webDAV with:

```shell
docker run --rm \
  -v davis-sqlite_davis_webdav:/data \
  -v "$PWD/backups":/backup \
  alpine \
  sh -c "rm -rf /data/* && tar xzf /backup/davis_webdav_YYYY-mm-dd.tar.gz -C /data"
```
