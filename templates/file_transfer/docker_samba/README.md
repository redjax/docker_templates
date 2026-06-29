# Samba

Dockerized Samba using [`ServerContainers/samba`](https://github.com/ServerContainers/samba).

## Setup

- Copy the [example `.env` file](./.env.example) to `.env`
  - Set `TZ` to your timezone
  - Set `SAMBA_SHARED_DIR` to the path on your host where files will be stored
- Copy the [example `smb.env` file](./example.smb.env) to `smb.env`
  - Create accounts
    - Each `ACCOUNT_<username>=password` becomes a valid SMB user
    - You can change passwords at any time and restart the container to reset the password
  - Add any accounts you create to the `SAMBA_SHARED_shared_VALIDUSERS` variable

Bring the container up with `docker compose up -d`

## Connecting to SMB

### Linux

Using a GUI file explorer, i.e. KDE Dolphin or Gnome Files:

- Navigate to `smb://<smb-username>@<smb-host-ip-or-fqdn>/shared`
  - This should prompt you to enter a user and password
  - Use one of the credentials from the `smb.conf` file

From the CLI using `smbclient`:

- Install `smbclient`
  - List available shares: `smbclient -L //<smb-host-ip-or-fqdn> -U <smb-username>`
  - Connect to a share: `smbclient //<smb-host-ip-or-fqdn>/shared -U <smb-username>`

## Overlays

You can add additional functionality to the stack using [overlays](./overlays/).

### Additional shares

Besides the default `/shares/shared`, you can create additional shares using overlays.

- Copy the [`example.share-additional.yml` overlay](./overlays/example.share-additional.yml) to a new file
  - Name it something like `share.sharename.yml`, replaceing `.sharename` with the name of your share, i.e. `music`
- Create a share environment file by copying the [`example.share.env` file](./envs/example.share.env) to `./envs/share.music.env`
  - Each share overlay should have its own `share.*.env` file.
  - These additional environments are merged with the root `.env` and default [`envs/smb.env`](./envs/smb.env), so you only need to add settings like `ACCOUNT_username` and `SAMBA_SHARED_shared_VALIDUSERS=username`

### User homes

Enable user homes with the [`user-homes.yml` overlay](./overlays/user-homes.yml). When you run the `docker compose` command, add it to the stack like:

```shell
docker compose -f compose.yml -f overlays/user-homes.yml up -d
```

Now, each logged in user will have their own private directory, i.e. `smb://smbUsername@<server-ip-or-fqdn>/smbUsername`. That user can only see their home directory, and no other users can see it.

