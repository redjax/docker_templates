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

