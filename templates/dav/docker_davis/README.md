# SQLite Version

Davis can [use SQLite as a backend](https://github.com/tchapi/davis/blob/main/docker/docker-compose-sqlite.yml). This is a portable, lightweight way to run Davis, suitable for a single user. For multiple users, or many simultaneous connections, it's better to use the MySQL or Postgres-backed versions.

## Instructions

- Copy the [example `.env` file](./.env.example) to `.env`
  - Change/set the following env vars:
    - `ADMIN_PASSWORD`: Set the Davis admin user's password.
      - To change this password, just set a new value and restart the container.
    - Enable CalDAV, CardDAV, and/or WebDAV by setting the corresponding env vars to `true`
    - Set `APP_TIMEZONE` to your timezone.
- Bring the stack up with `docker compose up -d`
- If this is the first time you're starting the containers on this machine, run the `first-launch-migrations.sh` script to do database migrations.
  - This is only required on new/fresh setups.
- Access the admin UI at `http://ip-or-fqdn:9000`
  - If you set a `DAVIS_PORT` value to something other than `9000`, use that port instead.
- Access the DAV interface at `http://ip-or-fqdn:9000/dav`.

## SMTP

If you plan to invite users to your calendar events, you will need to setup SMTP so they can get email notifications/invites. You can use a free SMTP provider like Gmail, or [Fastmail](https://fastmail.com) if you have an account.

### Gmail SMTP

First, create an [app password](https://support.google.com/accounts/answer/185833?hl=en) to use, allowing this app to bypass MFA. Then, edit the `MAILER_DSN` environment variable (edit [`.env`](./.env.example) for Docker, or [`.envrc.local`](.envrc) for `direnv`):

```plaintext
MAILER_DSN=smtp://your.full@gmail.com:your-app-password@smtp.gmail.com:587?encryption=tls&auth_mode=login
```

Set the `INVITE_FROM_ADDRESS` environment variable to a real email address you control.

### Fastmail SMTP

First, create an [app password](https://www.fastmail.help/hc/en-us/articles/360058752854-App-passwords) to use, allowing this app to bypass MFA. Then, edit the `MAILER_DSN` environment variable (edit [`.env`](./.env.example) for Docker, or [`.envrc.local`](.envrc) for `direnv`):

```plaintext
MAILER_DSN=smtp://user:pass@smtp.fastmail.com:465?encryption=ssl&auth_mode=login
```

Set the `INVITE_FROM_ADDRESS` environment variable to a real email address you control.
