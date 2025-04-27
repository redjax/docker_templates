# Pangolin

Reverse proxy & authentication server. Comparable to Cloudflare Tunnels & authentication servers like Authentik & Keycloak.

## Setup

- Copy example config files
  - Copy `./config/pangolin/example.config.yml` -> `./config/pangolin/config.yml`
  - Copy `./traefik/example.traefik_config.yml` -> `./traefik/example.traefik_config.yml`
  - Copy `./traefik/example.dynamic_cconfig.yml` -> `./traefik/dynamic_config.yml`
  - Copy `.env.example` -> `.env`
- Edit the configuration files
  - `./config/pangolin/config.yml`:
    - Set the URL for the Pangolin dashboard in `dashboard_url` under `app`. This will be the address for Pangolin's webUI.
    - Set your domain name in `base_domain`
    - Set the admin user's email in `users.server_admin.email`
    - Set the admin user's password in `users.server_admin.password`
  - `./traefik/example.traefik_config.yml`:
    - Set your admin email in `email: `
  - `./traefik/dynamic_config.yml`:
    - Set your domain name in the `rule: "Host(``)"` line.
  - `.env`
    - (Optional) If using Cloudflare and doing a DNS challenge, set your Cloudflare API token in `CLOUDFLARE_DNS_CHALLENGE_TOKEN`
- (Optional) [Setup Cloudflare DNS challenges](https://docs.fossorial.io/Pangolin/Configuration/wildcard-certs#wildcard-config-for-dns-01-challenge) using an API token for easier certificate setup.

### Cloudflare Setup

If you are using Cloudflare, create a CNAME record for your backend, i.e. `proxy.example.com` (replacing `example.com` with your domain). You must disable the full proxy, so the cloud icon is gray instead of orange. The Cloudflare free plan cannot proxy UDP traffic, which is what Pangolin/Newt use to maintain connectivity between the server & backend service.

## Troubleshooting

### Pangolin/Newt Not Connecting (ICMP ping timeout)

You may have trouble connecting your Pangolin (VPS/remote server) and Newt (local agent) machines, where the Newt container will fail to ping the Pangolin server, producing warnings and errors like this:

```shell
pangolin-newt  | INFO: YYYY/mm/dd HH:MM:SS Ping attempt 2
pangolin-newt  | INFO: YYYY/mm/dd HH:MM:SS Pinging 100.89.128.1
pangolin-newt  | WARN: YYYY/mm/dd HH:MM:SS Ping attempt 1 failed: failed to read ICMP packet: i/o timeout
```

When this happens, make sure you've opened your Wireguard port on the Pangolin server (default is `51820/udp`). You may also need to open this port on the local machine. You will need to allow traffic IN and OUT.

For example, with `ufw`:

```shell
sudo ufw allow in 51820/udp && sudo ufw allow out 51820/udp && sudo ufw reload
```

Start by opening this port only on the Pangolin server to see if it can connect; if you still have trouble connecting with the Newt container, run the commands above on the Newt container's host, too.
