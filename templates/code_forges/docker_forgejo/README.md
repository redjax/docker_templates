# Forgejo <!-- omit in toc -->

[Forgejo](https://forgejo.org) code for (alternative to Github).

## Table of Contents <!-- omit in toc -->

- [Setup](#setup)
  - [Local Network](#local-network)
  - [Publicly Exposed](#publicly-exposed)
  - [SSH Setup](#ssh-setup)
  - [Clone with SSH](#clone-with-ssh)
- [Troubleshooting](#troubleshooting)
  - [Init failed: mkdir /path/name](#init-failed-mkdir-pathname)
- [Links](#links)

## Setup

Run the [initial setup script](./scripts/initial_setup.sh) to create the `data/forgejo` directory, set the correct permissions, and copy example environment files in the [`env_files/` directory](./env_files/).

Start the stack, navigate to your URL, and complete the setup. Make sure to create an admin account (at the bottom of the page). The container will restart, at which point you should bring it down, edit your env file (default is `env_files/forgejo/default.env`) and set `FORGEJO__security__INSTALL_LOCK=true`, then bring the stack back up.

After registering a user, if you want to disable future registrations, update the [Forgejo env file](./env_files/forgejo/example.env), setting `FORGEJO__service__DISABLE_REGISTRATION=true`.

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

## Troubleshooting

### Init failed: mkdir /path/name

If you see an error like this in the container:

```shell
forgejo  | 2025/07/31 01:26:57 routers/init.go:62:mustInit() [F] forgejo.org/modules/storage.Init failed: mkdir /data/attachments: permission denied
forgejo  | Received signal 15; terminating.
```

make sure the host path in the `FORGEJO_DATA_DIR` [env variable](./.env.example) is owned by the `USER_UID` and `USER_GID` vars in [the forgejo app env file](./env_files/forgejo/example.env). For example, if set to `USER_UID=1000` and `USER_GID=1000`, run `chmod -R 1000:1000 ./data/forgejo.

## Links

- [Forgejo home](https://forgejo.org)
- [Forgejo docs](https://forgejo.org/docs/latest/)
- [Forgejo containers](https://codeberg.org/forgejo/-/packages/container/forgejo/versions)
