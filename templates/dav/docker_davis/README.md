# SQLite Version <!-- omit in toc -->

Davis can [use SQLite as a backend](https://github.com/tchapi/davis/blob/main/docker/docker-compose-sqlite.yml). This is a portable, lightweight way to run Davis, suitable for a single user. For multiple users, or many simultaneous connections, it's better to use the MySQL or Postgres-backed versions.

## Table of Contents <!-- omit in toc -->

- [Setup \& Usage](#setup--usage)
- [Connecting to Davis](#connecting-to-davis)
  - [DAV Paths](#dav-paths)
  - [Browse the webUI](#browse-the-webui)
- [SMTP](#smtp)
  - [Gmail SMTP](#gmail-smtp)
  - [Fastmail SMTP](#fastmail-smtp)
- [Proxying](#proxying)
- [Troubleshooting](#troubleshooting)
  - [500 error when accessing webUI](#500-error-when-accessing-webui)

## Setup & Usage

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

## Connecting to Davis

You can access the data in your Davis server with a calDAV/cardDAV client, and if you enable webDAV you can browse with a webDAV client.

You can access the admin route at `/dashboard`. For example, Thunderbird supports calDAV and cardDAV, and the Dolphin file explorer for KDE supports webDAV. iPhone has calDAV and cardDAV support build in, while Android users can use [Davx5](https://www.davx5.com/) to connect & synchronize with a DAV server.

### DAV Paths

Use a client that supports each protocol to access the DAV server.

| Proto | Endpoint |
| webDAV | `/dav/home/username` |
| calDAV | `/dav/calendars/username/calendar-name` |
| cardDAV | `/dav/addressbooks/username/address-book-name` |

### Browse the webUI

You can browse the SabreDAV backend by navigating to the `/dav` route and authenticating. Once signed in, you can click through the objects like calendars and address books, and explore the "nodes" (items) in each section.

If the user you authenticated with is an administrator (the `Is this user and administrator ?` box on the user's page in the admin UI), you will be able to explore other users' DAV paths. Otherwise, you will only see the paths available to the logged-in user.

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

## Proxying

If you use a reverse proxy with authentication like [Pangolin](https://pangolin.net/), you can protect the admin UI route while bypassing auth for DAV. Set a bypass rule for the `/dav/*` path.

## Troubleshooting

### 500 error when accessing webUI

If you get a 500 Internal Server Error when accessing the `/` or `/dav` routes, it most likely means you need to run the [`first-launch-migrations.sh` script](./first-launch-migrations.sh). This script initializes the database and creates the directories Davis uses, and sets the correct permissions inside the container/
