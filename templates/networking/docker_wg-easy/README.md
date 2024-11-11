# WireGuard Easy

`wg-easy` is a WireGuard VPN management tool that offers a web UI. This tool helps to spin up a WireGuard VPN server in Docker.

## Usage

- Copy `.env.example` -> `.env`
- Generate your admin password by running the [`generate_wg_password_hash.sh`](./generate_wg_password_hash.sh) script.
    - Copy the generated password into the `WG_EASY_ADMIN_PASSWORD_HASH` env variable in `.env`.
    - **NOTE**: You must replace any `$` characters with `$$`.
- Set your machine's hostname/address in `WG_EASY_HOST`
    - This can be an IP address or FQDN (i.e. `wg.your-domain.com`), but FQDN is preferred.
- Allow the following ports through your firewall:
    - `51820/udp` (WireGuard's communication port)
    - `51821/tcp` (WireGuard's webUI port)
- Run the stack with `docker compose up -d`
- Access the web UI at `http://<your-wireguard-hostname>:51821`

## Links

- [Github: wg-easy](https://github.com/wg-easy/wg-easy)
    - [Run WireGuard Easy](https://github.com/wg-easy/wg-easy?tab=readme-ov-file#2-run-wireguard-easy)
    - [WireGuard Docker env variables](https://github.com/wg-easy/wg-easy?tab=readme-ov-file#options)
    - [Using WireGuard Easy with NGINX SSL](https://github.com/wg-easy/wg-easy/wiki/Using-WireGuard-Easy-with-nginx-SSL)
