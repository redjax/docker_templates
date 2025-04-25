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
