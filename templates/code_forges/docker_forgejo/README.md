# Forgejo <!-- omit in toc -->

[Forgejo](https://forgejo.org) code forge (alternative to Github).

[Forgejo releases](https://forgejo.org/releases/).

## Table of Contents <!-- omit in toc -->

- [Setup](#setup)
  - [Admin Account Setup](#admin-account-setup)
    - [With INSTALL\_LOCK=false](#with-install_lockfalse)
    - [With INSTALL\_LOCK=true and DISABLE\_REGISTRATION=false](#with-install_locktrue-and-disable_registrationfalse)
  - [Local Network](#local-network)
  - [Publicly Exposed](#publicly-exposed)
  - [Caddy Server](#caddy-server)
  - [Protect Site with Anubis](#protect-site-with-anubis)
  - [SSH Setup](#ssh-setup)
  - [Clone with SSH](#clone-with-ssh)
  - [OAuth2 Provider Setup](#oauth2-provider-setup)
    - [Authentik OAuth2 setup](#authentik-oauth2-setup)
- [Backups](#backups)
  - [Offen Docker Volume Backup](#offen-docker-volume-backup)
    - [Test Offen Backup](#test-offen-backup)
    - [Restore Offen Backup](#restore-offen-backup)
      - [Restore on a new machine](#restore-on-a-new-machine)
      - [Download and extract the backup](#download-and-extract-the-backup)
      - [Stop Forgejo and the backup scheduler](#stop-forgejo-and-the-backup-scheduler)
      - [Restore to a host bind mount](#restore-to-a-host-bind-mount)
      - [Restore to a named Docker volume](#restore-to-a-named-docker-volume)
      - [Start and verify Forgejo](#start-and-verify-forgejo)
- [Setup Action Runner](#setup-action-runner)
- [Migrate Forgejo Repository to New Forgejo](#migrate-forgejo-repository-to-new-forgejo)
  - [Source Forgejo Instance](#source-forgejo-instance)
  - [Destination Forgejo Instance](#destination-forgejo-instance)
- [Troubleshooting](#troubleshooting)
  - [Init failed: mkdir /path/name](#init-failed-mkdir-pathname)
  - [Fastmail SMTP Not Working](#fastmail-smtp-not-working)
  - [Permission Errors](#permission-errors)
- [Links](#links)

## Setup

Run the [initial setup script](./scripts/initial_setup.sh) to create the `data/forgejo` directory, set the correct permissions, and copy example environment files in the [`env_files/` directory](./env_files/).

Start the stack, navigate to your URL, and complete the setup.

### Admin Account Setup

When `FORGEJO__security__INSTALL_LOCK=false`, the first boot of Forgejo will show a "first time setup" page, where you can edit the server instance and create an administrator account. If `FORGEJO__security__INSTALL_LOCK=true`, you will need to set `FORGEJO__service__DISABLE_REGISTRATION=false` in order to create an account. The first account created in Forgejo becomes the administrator.

#### With INSTALL_LOCK=false

Make sure to create an admin account (at the bottom of the page). The container will restart, at which point you should bring it down, edit your env file (default is `env_files/forgejo/default.env`) and set `FORGEJO__security__INSTALL_LOCK=true`, then bring the stack back up.

After registering a user, if you want to disable future registrations, update the [Forgejo env file](./env_files/forgejo/example.env), setting `FORGEJO__service__DISABLE_REGISTRATION=true`.

#### With INSTALL_LOCK=true and DISABLE_REGISTRATION=false

If the admin account you created does not work after setting the install lock to `true` and restarting the container, try setting the `FORGEJO__security__INSTALL_LOCK` variable to `true`, and `FORGEJO__service__DISABLE_REGISTRATION` to `false`, navigate to the webUI, and manually register a new account. The first account created in a Forgejo instance becomes the administrator.

### Local Network

To serve Forgejo internally on your LAN, you can run the `compose.yml` without the [`traefik` overlay](./overlay.traefik.yml).

Set the following environment variables in your [`forgejo.env`](./env_files/forgejo/example.env):

- `FORGEJO__server__DOMAIN=http://<your-dns-name-or-ip>`
- `FORGEJO__server__ROOT_URL=http://<your-dns-name-or-ip>`
- `FORGEJO__server__SSH_DOMAIN=<your-dns-name-or-ip>`

### Publicly Exposed

> [!WARNING]
> Setting up Forgejo to be exposed to the Internet can be tricky, and risky. These instructions are *not* meant to be "production ready," nor am I a security expert. This is the setup I personally use, and you should review it and understand the risks and be sure you are ok accepting them before running this container.

First, get a domain name, i.e. from [Porkbun](https://porkbun.com). This guide assumes you are using [Cloudflare](https://cloudflare.com), and have your domain name pointed to your Cloudflare account.

Create the following records, where `example.com` is your domain name:

- `A` record: Name=`example.com` Content=`<your-public-ip-address>` Proxy status=DNS only (grey cloud)
- `A` record: Name=`git.example.com` Content=`<your-public-ip-address>` Proxy status=proxied (orange icon)

See the [SSH setup section](#ssh-setup) for information on setting up SSH cloning with Forgejo.

On your router, forward the following ports:

- WAN: `80` -> LAN: `192.168.1.xxx:<your-traefik-http-port>`
- WAN: `443` -> LAN: `192.168.1.xxx:<your-traefik-https-port>`
- WAN: `222` (or whatever SSH port you're using for the Forgejo container) -> LAN: `192.168.1.xxx:<your-forgejo-host-ip>`

### Caddy Server

You can (and should) put Caddy in front of Forgejo when serving it publicly. Caddy is not included in this configuration, but you can create your own using the instructions below.

In a new directory, i.e. `~/docker_caddy`, create the following files:

- `compose.yml`:

  ```yaml
  ---
  name: caddy

  volumes:
    data: {}
    config: {}

  services:
    caddy:
      image: caddy:${CADDY_IMG_TAG:-2}
      restart: unless-stopped
      network_mode: host

      environment:
        DOMAIN: ${DOMAIN:-localhost}
        ACME_EMAIL: ${ACME_EMAIL:-admin@localhost}
        FORGEJO_DOMAIN: ${FORGEJO_DOMAIN:-${DOMAIN:-localhost}}
        FORGEJO_UPSTREAM: ${FORGEJO_UPSTREAM:-127.0.0.1:3000}

      volumes:
        - ${CADDYFILE:-./Caddyfile}:/etc/caddy/Caddyfile:ro
        - ${CADDY_DATA_DIR:-data}:/data
        - ${CADDY_CONFIG_DIR:-config}:/config
  ```

- `Caddyfile`:

  ```plaintext
  {
      email {$ACME_EMAIL}
  }

  {$FORGEJO_DOMAIN} {
      log
      reverse_proxy {$FORGEJO_UPSTREAM} {
          header_up X-Real-IP {remote_host}
          header_up X-Http-Version {http.request.proto}
          header_up X-TLS-SNI-Name {tls_server_name}
        }
  }
  ```

- And create a `.env` files, using the values relevant to your configuration:

  ```plaintext
  ## Default: 2
  CADDY_IMG_TAG=

  ## Default: localhost
  #  Use your domain with no protocol, i.e. my-git-domain.com
  DOMAIN=my-git-domain.com
  ## Default: admin@localhost
  ACME_EMAIL=address@example.com

  ## Default: localhost
  #  Use your domain or subdomain, i.e. my-git-domain.com
  #  or git.my-domain.com
  FORGEJO_DOMAIN=my-git-domain.com
  ## Default: 127.0.0.1:3000
  #  When using Anubis, proxy to the Anubis port, i.e.
  #  127.0.0.1:8923
  FORGEJO_UPSTREAM=
  ```

When using Caddy, you should only bind Forgejo's ports to `127.0.0.1:<port>`. This forces traffic through the Caddy proxy and prevents exposing the port directly.

### Protect Site with Anubis

This stack includes an optional layer for [Anubis](https://anubis.techaro.lol/). You can protect your site from some automated scans/interactions (i.e. LLM agents and other bots) by running the stack with [`-f overlay/anubis.yml`](./overlay.anubis.yml), i.e.:

```shell
docker compose -f compose.yml -f overlay.anubis.yml up -d
```

First, edit your `.env` file. At minimum, you need to set a v alue for `ANUBIS_SIGNING_KEY`, which you can generate with `openssl rand -hex32` or the [`./scripts/generate-secrets.sh` script](./scripts/generate-secrets.sh).

Next, update your [Caddy config](#caddy-server)'s `.env` file; set `FORGEJO_UPSTREAM=127.0.0.1:8923` (Anubis's port). When a request is made to your Forgejo instance, it hits Caddy, then Anubis, where a challenge must be passed to get to your site.

Path filters in the `overlay.anubis.yml` control which requests are challenged. This allows for Git HTTPS and SSH traffic to continue working.

### SSH Setup

**TL/DR**:

- Use a non-standard SSH port (i.e. something other than `22`)
- Disable root login
- Set connection timeouts & limits
- Disable password authentication, require keys
- Fail2Ban

It's not a wise idea to expose a machine with the default SSH configuration. Here are some things you should do on the host when exposing SSH for cloning.

- Edit `/etc/ssh/sshd_config`
  - Set a different SSH port
    - Find the line `#Port 22`, uncomment it, and set a different value.
    - Try to avoid using an easy port like `222`, set it to something semi-random, like `25934`
    - This allows you to bind port 22 on the host into the container directly.
  - Disable root login
    - Change `#PermitRootLogin yes` to `PermitRootLogin no`
  - Disable password-based authentication
    - Change `#PasswordAuthentication yes` to `PasswordAuthentication no`
  - Only allow SSH keys for login
    - Change `#PubkeyAuthentication no` to `PubkeyAuthentication yes`
  - (Optional) Only allow specific users, i.e. you and git
    - Add/edit a line `AllowUsers user1 user2 user3 ...`
  - Set idle timeout & connection limits, add or edit the following lines:
    - `ClientAliveInterval 300`
    - `ClientAliveCountMax 2`
    - `MaxAuthTries 3`
    - `MaxSessions 2`
  - Enable strong encryption algorithms
    - `Ciphers aes256-gcm@openssh.com,chacha20-poly1305@openssh.com`
    - `MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com`
    - `KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group14-sha1`
- Remember to restart SSH after making any changes to `/etc/ssh/sshd_config`: `sudo systemctl restart ssh`
- Setup [Fail2Ban](https://github.com/fail2ban/fail2ban)
  - With your host SSH and the Forgejo container SSH ports exposed, you should setup Fail2Ban to protect from brute force and other abuse
  - After installing Fail2Ban, copy the [preconfigured Fail2Ban SSH config](./fail2ban/ssh-multiport.conf) to `/etc/fail2ban/jail.d/`.
  - Optionally, you can create the file manually by making a file at `/etc/fail2ban/jail.d/ssh-multiport.conf` with the following contents:

```conf
[sshd]
enabled = true
## Add any SSH ports configured on the host, i.e. a non-standard port
#  to forward into Forgejo container's port 22, host 22 port, etc.
port = 22,255138
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 600
findtime = 600
```

- Restart Fail2Ban with `sudo systemctl restart fail2ban`

### Clone with SSH

After [setting up SSH](#ssh-setup), you can do the following to setup SSH cloning from your Forgejo instance:

- Create an SSH key
  - `ssh-keygen -t rsa -b 4096 -f ~/.ssh/forgejo_id_rsa -N ""`
- Copy the contents of `cat ~/.ssh/forgejo_id_rsa.pub`
  - In Forgejo, go to your settings and SSH keys, and add this key
- On the host where you created the SSH key, edit `~/.ssh/config` and add something like this, substituting your own values for `$DOMAIN` and `$PORT`:

```plaintext
Host $DOMAIN
  HostName $DOMAIN
  User git
  Port $PORT
  IdentityFile ~/.ssh/forgejo_id_rsa

```

Then, run `ssh $DOMAIN` and confirm the prompt to test it.

### OAuth2 Provider Setup

Forgejo can act as an OAuth2 provider for applications like [Woodpecker CI](https://woodpecker-ci.org/docs/administration/configuration/forges/forgejo). You must enable OAuth2 by setting `FORGEJO__oauth2__ENABLED=true` in your [Forgejo env file](./env_files/forgejo/example.env).

This will make OAuth2 application settings available in the Forgejo UI, under `Settings -> Applications -> Authorized OAuth2 applications`.

#### Authentik OAuth2 setup

If you are using Authentik as your IDP, you can create a Provider and Application for signing into Forgejo.

Authentik setup:

- Open the admin UI and navigate to "Applications > Providers"
- Create a new provider and choose "OAuth2/OpenID Provider"
  - Give the provider a name like "Forgejo"
  - Use the default authentication flow
  - Set Client Type to Confidential
  - Save the Client ID and Client Secret to a password manager. You will need them later in Forgejo
  - Set the Redirect URI to `https://YOUR_FORGEJO_ADDRESS/user/oauth2/Authentik/callback`
    - Include your Forgejo port if you're accessing with `http(s)://ip-address:port`
- Navigate to "Applications > Applications"
- Create a new Application using existing provider (use the dropdown next to the New Application button)
  - Give the application a name like "Forgejo"
  - Choose the Forgejo provider you created from the "Provider" dropdown

Forgejo Setup:

- Login to Forgejo as the admin user
- Go to "Site Administration"
- Navigate to "Identity & Access > Authentication sources" and add a new source. Use the following values:
  - Authentication type: OAuth2
  - Authentication name: Authentik
  - OAuth2 provider: OpenID Connect (scroll down in the list if you don't see it)
  - Paste the Client ID and Secret from the Authentik Provider
  - For Icon URL, use `https://auth.example.com/static/dist/assets/icons/icon.png`
  - For the OpenID Connect Auto Discovery URL, use: `https://auth.twistp.ing/application/o/forgejo/.well-known/openid-configuration`
  - Set "Additional scopes" to `email profile`

## Backups

### Offen Docker Volume Backup

The [`overlay.offen-backup.yml` layer](./overlay.offen-backup.yml) can backup your Forgejo Docker volumes using [`offen/docker-volume-backups](https://github.com/offen/docker-volume-backup). This container is configured to backup to S3 compatible storage (AWS S3, Wasabi, Backblaze B2, etc) on a schedule defined by the user (default: 4:30AM daily in the configured timezone).

To set up backups:

- Edit your `.env` file's `Offen backup` section
- Set your timezone in `OFFEN_BACKUP_TZ`
- Optionally change the cron schedule in `OFFEN_BACKUP_CRON`
- Create a bucket in your S3 storage and put its name in `OFFEN_BACKUP_S3_BUCKET`
- If you have a folder in the bucket for Forgejo backups, add the path in `OFFEN_BACKUP_S3_PREFIX`
- Set your endpoint (should be available in the webUI for your S3 storage) in `OFFEN_BACKUP_S3_ENDPOINT`
  - For example, Wasabi US East 1 (N. Virginia) uses `s3.wasabisys.com`; US East 2 uses `s3.us-east-2.wasabisys.com`.
- Put your access key and secret in `OFFEN_BACKUP_S3_ACCESS_KEY_ID` and `OFFEN_BACKUP_S3_SECRET_ACCESS_KEY`
- Generate a passhprase with `openssl rand -hex 32` or `./scripts/generate-secrets.sh` and paste the value into `OFFEN_BACKUP_AGE_PASSPHRASE`
- Optionally set a number of days for backup retention in `OFFEN_BACKUP_RETENTION_DAYS`
- If you use Gotify, you can set notifications by putting a URL in `OFFEN_BACKUP_NOTIFICATION_URLS`, i.e.:
  - `OFFEN_BACKUP_NOTIFICATION_URLS='gotify://gotify.example.com:443/YOUR_APPLICATION_TOKEN/?title=Forgejo+backups&priority=5'`
- You can filter notifications by log level using `OFFEN_BACKUP_NOTIFICATION_LEVEL`

To start the Offen backup container, use `-f overlay.offen-backup.yml` with your `docker compose` command. Examples:

Forgejo + Offen:

```shell
docker compose -f compose.yml -f overlay.offen-backup.yml up -d
```

With [Anubis](#protect-site-with-anubis):

```shell
docker compose -f compose.yml \
  -f overlay.anubis.yml \
  -f overlay.offen-backup.yml \
  up -d
```

#### Test Offen Backup

Run a manual backup. This temporarily stops Forgejo:

```shell
docker compose -f compose.yml \
  -f overlay.offen-backup.yml \
  exec offen-backup backup
```

If using [Anubis](#protect-site-with-anubis), include `-f overlay.anubis.yml` as in the startup command. The backup command runs the backup immediately instead of waiting for the schedule.

Afterward, confirm:

- Forgejo is running again.
- An encrypted `.tar.gz.age` archive appeared in your bucket.
- A Gotify notification arrived, if enabled with notification level `info`.

View Offen's backup logs with:

```shell
docker compose -f compose.yml \
  -f overlay.offen-backup.yml \
  logs --tail=100 offen-backup
```

#### Restore Offen Backup

> [!WARNING]
> Stop Forgejo and the backup scheduler before replacing any data. Preserve the existing data until the restored instance has been verified.

The examples below assume the archive contains a `data/` directory. Check the archive layout and adjust the source path if necessary.

##### Restore on a new machine

Prepare the repository, `.env`, and external configuration files first. These deployment files are not included in the data-only backup. Use the same Forgejo image version as the backed-up installation for the initial restore. Keep existing instance secrets consistent with the restored configuration; do not overwrite them with newly generated values or placeholders.

Do not run `docker compose up` yet.

Create Forgejo’s container and storage without starting the application:

```shell
docker compose -f compose.yml \
  -f overlay.offen-backup.yml \
  create forgejo
```

Include `-f overlay.anubis.yml` if it is part of your deployment.

Find the named volume that Compose created for `/data`:

```shell
CID=$(docker compose -f compose.yml \
  -f overlay.offen-backup.yml \
  ps -aq forgejo)

DATA_VOLUME=$(docker inspect "$CID" --format \
  '{{range .Mounts}}{{if and (eq .Destination "/data") (eq .Type "volume")}}{{.Name}}{{end}}{{end}}')

test -n "$DATA_VOLUME" || {
  echo "No named volume found at /data; stopping." >&2
  exit 1
}

printf 'Restoring into volume: %s\n' "$DATA_VOLUME"
```

After decrypting and extracting the backup, confirm the source directory contains your Forgejo data:

```shell
sudo ls -la "$RESTORE_DIR/data"
```

Restore into the new volume. The command stops if the destination is not empty:

```shell
sudo test -d "$RESTORE_DIR/data" || exit 1

docker run --rm \
  --mount "type=bind,source=$RESTORE_DIR/data,target=/restore,readonly" \
  --mount "type=volume,source=$DATA_VOLUME,target=/destination" \
  alpine:3.22 \
  sh -ec '
    test -n "$(ls -A /restore)" || {
      echo "Restore source is empty; stopping." >&2
      exit 1
    }

    test -z "$(ls -A /destination)" || {
      echo "Destination is not empty; use the existing-volume restore procedure." >&2
      exit 1
    }

    cp -a /restore/. /destination/
  '
```

Start the restored installation using your usual overlay list:

```shell
docker compose -f compose.yml \
  -f overlay.anubis.yml \
  -f overlay.offen-backup.yml \
  up -d
```

Omit the Anubis overlay if it is not enabled.

Forgejo should use the restored database and configuration rather than presenting a fresh installation wizard. Verify login, repositories, and cloning before enabling normal traffic or relying on scheduled backups. For a host bind mount, the process is similar: restore into the configured host data directory before starting Forgejo.

##### Download and extract the backup

Download the desired `.tar.gz.age` archive from your bucket, then decrypt it using your backup passphrase:

```shell
age --decrypt \
  --output forgejo-backup.tar.gz \
  downloaded-backup.tar.gz.age
```

Extract it into an empty temporary directory and inspect it:

```shell
tar -tzf forgejo-backup.tar.gz | head -n 30

RESTORE_DIR="$(mktemp -d)"

sudo tar --numeric-owner -xzpf forgejo-backup.tar.gz \
  -C "$RESTORE_DIR"

sudo ls -la "$RESTORE_DIR/data"
```

Run the remaining commands in the same shell so that `$RESTORE_DIR` remains available.

##### Stop Forgejo and the backup scheduler

From your Forgejo Compose directory, run:

```shell
docker compose -f compose.yml \
  -f overlay.offen-backup.yml \
  stop offen-backup forgejo
```

Include `-f overlay.anubis.yml` if it is part of your deployment.

Choose the appropriate restore method below.

##### Restore to a host bind mount

Set `DATA_DIR` to the absolute host directory mounted at `/data`. Use the actual path configured for your deployment:

```shell
DATA_DIR=/absolute/path/to/data/forgejo
```

Confirm the paths, preserve the existing directory, and restore into an empty replacement:

```shell
sudo test -d "$RESTORE_DIR/data" || exit 1
test -n "$DATA_DIR" && test -d "$DATA_DIR" || exit 1

printf 'Restoring from: %s\nRestoring to: %s\n' \
  "$RESTORE_DIR/data" "$DATA_DIR"

OLD_DATA_DIR="${DATA_DIR}.before-restore-$(date +%Y%m%d-%H%M%S)"

sudo mv -- "$DATA_DIR" "$OLD_DATA_DIR"
sudo mkdir -p -- "$DATA_DIR"

sudo cp -a "$RESTORE_DIR/data/." "$DATA_DIR/"
```

Copy the contents of the extracted `data` directory. The resulting layout should match the original `/data` mount.

> [!NOTE]
> Keep enough free space for the extracted backup, restored data, and preserved original data. If necessary, move the original data to another disk or machine first.

##### Restore to a named Docker volume

Restore directly into the existing volume These commands assume you have already extracted the backup into `$RESTORE_DIR/data` and stopped Forgejo and the backup scheduler.

Find the actual volume mounted at Forgejo’s `/data`:

```shell
CID=$(docker compose -f compose.yml \
  -f overlay.offen-backup.yml \
  ps -aq forgejo)

DATA_VOLUME=$(docker inspect "$CID" --format \
  '{{range .Mounts}}{{if and (eq .Destination "/data") (eq .Type "volume")}}{{.Name}}{{end}}{{end}}')

test -n "$DATA_VOLUME" || {
  echo "No named volume found at /data; stopping." >&2
  exit 1
}

printf 'Volume to restore: %s\n' "$DATA_VOLUME"
docker volume inspect "$DATA_VOLUME"
```

Include your usual additional overlays in the Compose command if applicable. Before proceeding, confirm the volume name and check that the extracted backup contains the expected Forgejo files:

```shell
sudo ls -la "$RESTORE_DIR/data"
```

> [!WARNING]
> The next command deletes the existing volume contents before restoring the backup. Ensure Forgejo and any other containers that write to this volume are stopped. Preserve a separate backup of the current data if you may need to roll back.

Restore the backup into the existing volume:

```shell
sudo test -d "$RESTORE_DIR/data" || exit 1

docker run --rm \
  --mount "type=bind,source=$RESTORE_DIR/data,target=/restore,readonly" \
  --mount "type=volume,source=$DATA_VOLUME,target=/destination" \
  alpine:3.22 \
  sh -ec '
    test -n "$(ls -A /restore)" || {
      echo "Restore source is empty; stopping." >&2
      exit 1
    }

    find /destination -mindepth 1 -maxdepth 1 \
      -exec rm -rf -- {} \;

    cp -a /restore/. /destination/
  '
```

This replaces the contents of the volume, essentially wiping any existing data. Start the stack again using your usual overlay list:

```shell
docker compose -f compose.yml \
  -f overlay.anubis.yml \
  -f overlay.offen-backup.yml \
  up -d
```

Omit the Anubis overlay if it is not enabled. Verify startup logs, login, and repository access before considering the restore complete.

##### Start and verify Forgejo

Recreate the containers so Forgejo and the backup service use the restored directory or volume. Use your deployment’s usual overlay list:

```shell
docker compose -f compose.yml \
  -f overlay.anubis.yml \
  -f overlay.offen-backup.yml \
  up -d --force-recreate
```

Omit the Anubis overlay if it is not enabled.

Check Forgejo’s startup logs:

```shell
docker compose -f compose.yml \
  -f overlay.anubis.yml \
  -f overlay.offen-backup.yml \
  logs --tail=100 forgejo
```

Verify that you can log in, open repositories, and clone a repository. Check attachments and LFS objects if used.

Keep the original data directory or Docker volume until recovery has been verified.

## Setup Action Runner

See the [Forgejo runner container](./forgejo_runner/) for setup instructions. You must enable Actions on the server by setting `FORGEJO__actions__ENABLED=true`.

## Migrate Forgejo Repository to New Forgejo

Export the repository and its metadata on the source instance, copy the export to the destination host, and restore it into a new repository.

This example migrates `owner/ex-repo` into `owner/ex-repo-import`, including Git history, tags, releases, and uploaded release attachments.

> [!NOTE]
> Run commands from each instance’s Compose directory (wherever you run `docker compose up -d` for Forgejo). Add your usual Compose overlay arguments where necessary. Replace the example token, SSH username, hostname, and administrative SSH port if your configuration is different.

### Source Forgejo Instance

- Create a temporary personal access token in the source Forgejo with read access to the repository and its metadata.
- Export the repository into a fresh directory. Omitting `--units` includes all supported migration units (releases, issues, wikis, etc):

  ```shell
  docker compose exec --user git forgejo \
    forgejo dump-repo \
      --git_service gitea \
      --clone_addr "http://<forgejo-ip-and-port-or-fqdn>/owner/ex-repo" \
      --auth_token "YOUR_SOURCE_ACCESS_TOKEN" \
      --repo_dir /data/ex-repo-export \
      --owner_name owner \
      --repo_name ex-repo
  ```

  > [!CAUTION]
  > Putting the token directly in the command can save it in shell history. Revoke the temporary token when the export is complete.

- After the export finishes successfully, copy it out of the container:

  ```shell
  docker compose cp \
    forgejo:/data/ex-repo-export \
    ./ex-repo-export
  ```

- Package the export:

  ```shell
  tar -czf ex-repo-export.tar.gz \
    -C ex-repo-export .
  ```

- Copy the archive to the destination (the "new" Forgejo instance's host):

  ```shell
  scp -P YOUR_ADMIN_SSH_PORT \
    ex-repo-export.tar.gz \
    YOUR_SSH_USER@YOUR_VPS:~/
  ```

### Destination Forgejo Instance

- Ensure the destination owner exists (the `owner` user in this example). Do not create an empty `ex-repo-import` repository first. Importing this repository will create it.
- Extract the transferred archive:

  ```shell
  mkdir -m 700 ~/ex-repo-export

  tar -xzf ~/ex-repo-export.tar.gz \
    -C ~/ex-repo-export
  ```

- Create an import directory inside the running destination Forgejo container:

  ```shell
  docker compose exec --user git forgejo \
    mkdir -p /data/ex-repo-import
  ```

- Copy the extracted files into it and set ownership:

  ```shell
  docker compose cp \
    ~/ex-repo-export/. \
    forgejo:/data/ex-repo-import/

  docker compose exec --user root forgejo \
    chown -R git:git /data/ex-repo-import
  ```

- Inspect the directory layout:

  ```shell
  docker compose exec --user git forgejo \
    find /data/ex-repo-import -maxdepth 3 -type f
  ```

  The restore command must point to the individual repository’s exported directory. The command below assumes it is `/data/ex-repo-import/owner/ex-repo`; adjust that path if the export has a different layout.

- Restore under the temporary repository name:

  ```shell
  docker compose exec --user git forgejo \
    forgejo restore-repo \
      --config /data/gitea/conf/app.ini \
      --repo_dir /data/ex-repo-import/owner/ex-repo \
      --owner_name owner \
      --repo_name ex-repo-import
  ```

  Replace the configuration path if your installation uses a different one.

- Open `owner/ex-repo-import` in the destination web interface. Check repository visibility, branches, tags, releases, and uploaded attachments before replacing or renaming any existing repository.
- Once verified, rename the imported repository through its settings if desired. Keep the source repository and export until the destination has been backed up.

This process does not import repository settings like branch protection policies and Actions secrets/variables. You will need to manually recreate those.

## Troubleshooting

### Init failed: mkdir /path/name

If you see an error like this in the container:

```shell
forgejo  | 2025/07/31 01:26:57 routers/init.go:62:mustInit() [F] forgejo.org/modules/storage.Init failed: mkdir /data/attachments: permission denied
forgejo  | Received signal 15; terminating.
```

make sure the host path in the `FORGEJO_DATA_DIR` [env variable](./.env.example) is owned by the `USER_UID` and `USER_GID` vars in [the forgejo app env file](./env_files/forgejo/example.env). For example, if set to `USER_UID=1000` and `USER_GID=1000`, run `chown -R 1000:1000 ./data/forgejo`.

### Fastmail SMTP Not Working

If you are attempting to configure SMTP with [Fastmail](https://fastmail.com), and you are using `smtp.fastmail.com:587` but getting timeouts when trying to send test emails, you might need to use the HTTPS proxy (`smtps-proxy.fastmail.com`).

Set the following values in the [`env_files/forgejo/default.env`](./env_files/forgejo/example.env) file, using your real username, password/token, and FROM address(es):

> [!NOTE]
> For the `FORGEJO__mailer__FROM` address, you must own the address. You can use one of Fastmail's masked or custom addresses to obscure your real account in messages from Forgejo.

```plaintext
FORGEJO__mailer__ENABLED=true
FORGEJO__mailer__PROTOCOL=smtps
FORGEJO__mailer__SMTP_ADDR=smtps-proxy.fastmail.com
FORGEJO__mailer__SMTP_PORT=443
FORGEJO__mailer__USER=your-fastmail-username@fastmail.com
## Account password or access token
FORGEJO__mailer__PASSWD=<your fastmail app token>
## Can be different from the username value above; you must own the address/alias
FORGEJO__mailer__FROM=your-sender-address@fastmail.com

```

### Permission Errors

If you get permission errors when using a host volume mount, i.e. `./data/forgejo`, especially during Forgejo's initial setup with the `gitea.db` file, you likely skipped running the [`./scripts/initial_setup.sh` script](./scripts/initial_setup.sh).

Try fixing the container permissions:

```shell
## Stop the running containers
docker compose down

## Fix directory permissions
sudo chown -R 1000:1000 ./data/forgejo

## Restart container
docker compose up -d
```

## Links

- [Forgejo home](https://forgejo.org)
- [Forgejo docs](https://forgejo.org/docs/latest/)
- [Forgejo containers](https://codeberg.org/forgejo/-/packages/container/forgejo/versions)
