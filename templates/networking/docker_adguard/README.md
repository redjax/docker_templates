# Adguard Home <!-- omt in toc -->

Adblocking & DNS server.

- [Docker Hub: Adguard Home](https://hub.docker.com/r/adguard/adguardhome)

## Table of Contents <!-- omit in toc -->

- [Adguard Home ](#adguard-home-)
  - [Troubleshooting](#troubleshooting)
    - [Fix 'failed to bind port 0.0.0.0:53/tcp'](#fix-failed-to-bind-port-000053tcp)
    - [Use AdGuard Home for DNS on the host running the container](#use-adguard-home-for-dns-on-the-host-running-the-container)
      - [Additional notes and recommendations](#additional-notes-and-recommendations)

## Troubleshooting

### Fix 'failed to bind port 0.0.0.0:53/tcp'

Error:

```shell
Error response from daemon: driver failed programming external connectivity on endpoint adguard (097553a421ded4f491e324728592a6dd6f68d0f20515983ebb10254a69534da8): failed to bind port 0.0.0.0:53/tcp: Error starting userland proxy: listen tcp4 0.0.0.0:53: bind: address already in use
```

This error means that port `:53` (DNS port) is already in use on the host and can't be bound in the AdGuard Home container. You can check which service is using port `:53` with `lsof`:

```bash
user@host$ sudo lsof -i ":53"
COMMAND   PID            USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
systemd-r 927 systemd-resolve   14u  IPv4  10065      0t0  UDP _localdnsstub:domain 
systemd-r 927 systemd-resolve   15u  IPv4  10066      0t0  TCP _localdnsstub:domain (LISTEN)
systemd-r 927 systemd-resolve   16u  IPv4  10067      0t0  UDP _localdnsproxy:domain 
systemd-r 927 systemd-resolve   17u  IPv4  10068      0t0  TCP _localdnsproxy:domain (LISTEN)
```

If you see `systemd-resolve`, you can disable this following the instructions below:

- Edit `/etc/systemd/resolved.conf`
  - Look for the line `#DNSStubListener=yes`
  - Uncomment the line and change the `yes` to `no`
- Restart `systemd-resolved` with: `sudo systemctl restart systemd-resolved`
- Backup and replace `/etc/resolv.conf`:
  - `sudo mv /etc/resolv.conf /etc/resolv.conf.bak`
  - `sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf `
- To undo this change if you want to re-enable `systemd-resolve`:
  - remove the link you created at `/etc/resolv.conf`
  - Create a new linke from `/run/systemd/resolve/stub-resolv.conf /etc/resolv.conf`
    - `sudo ln -s /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf`
  - Edit `/etc/systemd/resolved.conf` to:
    - `DNSStubListener=yes`
  - Restart `systemd-resolved` again: `sudo systemctl restart systemd-resolved`

### Use AdGuard Home for DNS on the host running the container

On the machine running AdGuard Home, you can set DNS resolution to the AdGuard container using the instructions below:

- Create the directory if it does not exist:
  - `sudo mkdir -p /etc/systemd/resolved.conf.d/`
- Create `/etc/systemd/resolved.conf.d/adguardhome.conf` with:

```plaintext
[Resolve]
DNS=127.0.0.1
FallbackDNS=1.1.1.1
DNSStubListener=no
```
  - This disables the stub listener and sets your machine to use AdGuard Home at localhost
- Restart `systemd-resolved` with `sudo systemctl restart systemd-resolved`
  - Check that `systemd-resolved` restarted correctly with `systemd-resolve --status` or  `resolvectl status`
- Verify with: `resolvectl status`
- Ensure `/etc/resolv.conf` is a symlink to `/run/systemd/resolve/resolv.conf` (not the stub):
  - `sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf`

#### Additional notes and recommendations

- The order matters: disable stub listener and update `/etc/resolv.conf` before restarting the service to avoid DNS issues.
- Always backup original config files before making changes.
- Confirm that the AdGuard Home container is configured to listen on `127.0.0.1:53` or all interfaces so it can accept DNS queries from the host.
- The fallback DNS `1.1.1.1` will be used only if AdGuard Home does not respond.
- Using a drop-in config file is recommended for easier maintenance and rollback.
