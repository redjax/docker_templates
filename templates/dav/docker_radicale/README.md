# Radicale

[Radicale](https://radicale.org/v3.html) is a lightweight CalDAV and CardDAV server.

## Setup

- Run the [`initial-setup.sh` script](./init-setup.sh) if this is a fresh clone/new setup.
- Run `docker compose up -d` to bring the stack up.
- Manage users with the included [scripts](./scripts)
  - `new-radicale-user.sh`: Guided prompts for creating a new Radicale user.
  - `list-radicale-users.sh`: List all users found in `config/users`.
  - `change-radicale-user-password.sh`: Guided prompts for selecting a user and changing their password.
  - `delete-radicale-user.sh`: Delete a user by username.
- Backup calendars & address books (collections) with the [`backup-radicale.sh` script](./scripts/backup-radicale.sh).
  - Backups are owned by the `root` user by default. If you want to change the user, you can use `chown -R $USER:$USER backups/`, or run the [`fix-backup-owner.sh` script](./scripts/fix-backup-owner.sh).
  - You can restore a backup later with the [`restore-radicale-backup.sh` script](./scripts/restore-radicale-backup.sh).

After doing the initial setup, you should access the webUI at `http://ip-or-fqdn:5232`. Login with one of the users you created (or create one with the [`new-radicale-user.sh` script](./scripts/new-radicale-user.sh)). You will be taken to the user'ss Collections page. Click the `+` button to create a new collection (CalDAV, CardDAV, etc).

### Client setup

After doing the [initial setup](#setup) and creating a Collection, you can use a DAV client to synchronize your calendars/contacts. In the webUI where you can see your collections, not the URL for the collection you want to add. The collection URL will look like:

```plaintext
http://ip-or-fqdn:5232/username/3296f82e-7f1b-4416-9d6f-8be7f2ccf888/
```

> [!NOTE]
> If you put Radicale behind a reverse proxy, i.e. `https://dav.example.com`, use that address instead of `http://ip-or-fqdn:5232`. If you access Radicale using the proxied address, the URL shown in the collection will use the proxied URL.

Follow the setup instructions for your client, i.e. [Thunderbird](https://www.thunderbird.net/en-US/), [Davx5](https://github.com/bitfireAT/davx5-ose) (for Android), etc. When setting up synchronization with the client, use the collection's URL (CalDAV for calendar/todo/journal synch, CardDAV for address book synch), and your Radicale username and password.
