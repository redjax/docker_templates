# Forgejo <!-- omit in toc -->

[Forgejo](https://forgejo.org) code for (alternative to Github).

## Table of Contents <!-- omit in toc -->

- [Setup](#setup)
  - [SSH](#ssh)
    - [Secure SSH setup](#secure-ssh-setup)
- [Troubleshooting](#troubleshooting)
  - [Init failed: mkdir /path/name](#init-failed-mkdir-pathname)
- [Links](#links)

## Setup

Run the [initial setup script](./scripts/initial_setup.sh) to create the `data/forgejo` directory, set the correct permissions, and copy example environment files in the [`env_files/` directory](./env_files/).

Start the stack, navigate to your URL, and complete the setup. Make sure to create an admin account (at the bottom of the page). The container will restart, at which point you should bring it down, edit your env file (default is `env_files/forgejo/default.env`) and set `FORGEJO__security__INSTALL_LOCK=true`, then bring the stack back up.

After registering a user, if you want to disable future registrations, update the [Forgejo env file](./env_files/forgejo/example.env), setting `FORGEJO__service__DISABLE_REGISTRATION=true`.

### SSH

SSH setup for cloning is tricky... the way I normally do it is:

- A domain name forwarded to Cloudflare
  - An `ANAME` record to proxy, with DNS protection **OFF** (gray cloud icon)
    - This record should be something like `ssh.domain.com`
  - A `CNAME` record for the webUI proxy
    - i.e. `git.domain.com`
- A reverse web proxy on a VPS (i.e. [Pangolin](https://github.com/fosrl/pangolin))
  - I create 2 resources:
    - A reverse web proxy for `git.domain.com`, which forwards to the Forgejo host's webUI port (default: 3000)
    - A raw TCP/UDP forward to the host's SSH port (default is 22, recommended to change to a default port)
- If using a different subdomain, i.e. `git.domain.com` and `ssh.domain.com`, update the [Forgejo env file](./env_files/forgejo/example.env), change `FORGEJO__ssh__DOMAIN`
- Disable password authentication, require keys
- Fail2Ban (check the [Secure SSH Setup section](#secure-ssh-setup))

#### Secure SSH setup

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
