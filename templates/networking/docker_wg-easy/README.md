# WireGuard Easy

`wg-easy` is a WireGuard VPN management tool that offers a web UI. This tool helps to spin up a WireGuard VPN server in Docker.

## Requirements

- Docker
- (Optional, recommended) a static IP address
- (Optional, recommended) a domain name or dynamic DNS hostname

## Usage

- [Install Docker](https://docs.docker.com/engine/install/)
- [Install WireGuard](https://www.wireguard.com/install/)
- Create a Docker network
  - `docker network create --subnet 172.22.0.0/16 dns`
  - In the above example you can use any Docker subnet, changing the `x`s, i.e. `172.xx.0.0/16`
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

## Notes

### Fix no internet/ping while connected to WireGuard network

If you connect to your `wg-easy` network and cannot load/ping websites like `www.google.com`, you need to add the container's Docker network and your host's local network to the [`.env`](./.env.example)'s `WG_EASY_ALLOWED_IPS=` env variable.

First, get your machine's IP address:

```shell
$> ip a

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 96:00:03:d3:25:6c brd ff:ff:ff:ff:ff:ff
    altname enp1s0
    inet xxx.xxx.xxx.xxx/xx brd xxx.xxx.xxx.xxx scope global dynamic eth0  #<-- copy your IP address, change the last .xxx to 0 and use the same /xx
       valid_lft 58420sec preferred_lft 58420sec
    inet6 2a01:4ff:f0:a136::1/64 scope global 
       valid_lft forever preferred_lft forever
    inet6 fe80::9400:3ff:fed3:256c/64 scope link 
       valid_lft forever preferred_lft forever

```

In the example above, the interface `eth0` has an `inet` address listed. If you're on a home network you might see an address like `192.168.1.218/24`. Your first `WG_EASY_ALLOWED_IP=` should be `192.168.1.0/24`.

Next, run your `wg-easy` container with `docker compose up -d`, then run `docker compose exec -it wg-easy /bin/bash` and get the container's IP address:

```shell
## Inside Docker container
$> ip a

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host proto kernel_lo 
       valid_lft forever preferred_lft forever
2: wg0: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1420 qdisc noqueue state UNKNOWN group default qlen 1000
    link/none 
    inet xxx.xxx.xxx.xxx/xx scope global wg0
       valid_lft forever preferred_lft forever
269: eth0@if270: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:ac:15:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.21.0.2/16 brd 172.21.255.255 scope global eth0  #<-- copy your IP address, change the last .xxx to 0 and use the same /xx
       valid_lft forever preferred_lft forever

```

In the above example, the container also has an `eth0` interface, with an IP address of `172.21.0.2/16`. Your second IP address in `WG_EASY_ALLOWED_IPS=` should be `172.21.0.2/16`.

Your final `WG_EASY_ALLOWED_IPS=` should look like:

```text
## .env

...

WG_EASY_ALLOWED_IPS=192.168.1.0/24,172.21.0.0/16

...
```

**!! WARNING !!**

Your Docker container's `eth0` network can and will change, especially between hosts. If things stop working, check the container's IP address first, and make sure `WG_EASY_ALLOWED_IPS=` contains the right subnet!

## Links

- [Github: wg-easy](https://github.com/wg-easy/wg-easy)
    - [Run WireGuard Easy](https://github.com/wg-easy/wg-easy?tab=readme-ov-file#2-run-wireguard-easy)
    - [WireGuard Docker env variables](https://github.com/wg-easy/wg-easy?tab=readme-ov-file#options)
    - [Using WireGuard Easy with NGINX SSL](https://github.com/wg-easy/wg-easy/wiki/Using-WireGuard-Easy-with-nginx-SSL)
- [Use WireGuard with DNS container i.e. PiHole](https://hugopersson.com/blog/wg-easy-docker-with-dns/)
