# Bookstack

[Bookstack](https://www.bookstackapp.com) is a simple & free wiki software.

## Setup

> [!NOTE]
> For some reason, Bookstack does not play nicely with Docker volumes. This compose file uses host volume mounts.
>
> You must ensure the `$PUID` and `$PGID` env vars are set correctly. Find them by running:
>
> ```shell
> id $USER
> ```
>
> You might see something like this:
>
> ```shell
> uid=1000(username) gid=995(groupname) groups=995(groupane),27(sudo)
> ```
>
> If `gid=1000`, you can leave `$PUID` and `PGID` empty to use the default `1000:1000`, but if you see a different value for either `uid` or `gid`, make sure to set them correctly in the `.env` file.

- Copy the [example `.env`](./.env.example) to `.env`
- Generate a database root password with `./generate_db_root_pass.sh`
  - Copy the generated password into `.env`'s `DB_ROOT_PASSWORD`
- Generate the app secret with `./generate_app_key.sh`
  - Copy the generated secret into `.env`'s `BOOKSTACK_APP_KEY`
- Run `docker compose up -d`

Your Bookstack webUI will be available at the address you set in `BOOKSTACK_APP_URL`. The default admin login is:

|          |                   |
| -------- | ----------------- |
| Username | `admin@admin.com` |
| Password | `password`        |

## Troubleshooting

### Fix Unknown Error Occurred

When creating a new Book, you might see "An unknown error occurred." This is usually due to permission errors in the container. If you are using the default `PUID=1000` and `PGID=1000`, check that your Linux user's ID matches:

```shell
id $USER
```

Copy the `uid=` and `gid=` into `PUID=` and `PGID=`, then restart the container.

### LAN access login page loads but home page doesn't

This has happened to me when running Bookstack on my LAN, where I have DNS entries for hosts like `host1.home`. Make sure you are navigating to the exact same URL you set in `APP_URL`.

For example, if `APP_URL=bookstack.home:8080`, and `bookstack.home` resolves to `192.168.1.10`, if you navigate to `http://192.168.1.10` but the redirect to `bookstack.home:8080` might break. Use `http://bookstack.home:8080` instead.

