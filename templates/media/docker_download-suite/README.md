# Docker download suite <!-- omit in toc -->

*Arr stack with networking configurations. Supports binding ports straight to the host, or through a VPN using `gluetun` (OpenVPN and Wireguard supported).

## Table of Contents <!-- omit in toc -->

- [Containers](#containers)
- [Setup](#setup)
  - [Setup: Host Networking, No VPN](#setup-host-networking-no-vpn)
  - [Setup: VPN](#setup-vpn)
    - [Gluetun](#gluetun)
    - [NordVPN](#nordvpn)

## Containers

- Bazarr: For subtitle downloads
- Jackett: For torrent indexers
- LazyLibrarian: eBook downloads (essentially deprecated in this stack, I don't use it)
- Readarr: eBook downloads (project has been broken for years at this point, use Chaptarr instead)
- Chaptarr: eBook downloads
- Sonarr: Tv-show downloads
- Radarr: Movie downloads
- VPN: Linuxserver's NordVPN container or a Gluetun container
  - Useful if your seedbox provides a VPN configuration/connection
  - Torrent client options:
    - Deluge
    - Transmission
    - qBittorrent

## Setup

- Copy the [example `.env` file](./.env.example) to `.env`
  - Depending on the containers you're running, edit any values you want to override.
  - Check the [`compose.yml` file](./compose.yml) to see the containers that always run, i.e. `jackett`, `sonarr`, and `radarr`, then make sure to double check the default environment variables in `.env`
  - For [overlays you run](./overlays/), check the default variables for those services
- Choose the type of stack you want to run (see sections below)

### Setup: Host Networking, No VPN

When you are not using a VPN, always run the stack with the [`novpn-network.yml`](./overlays/novpn-network.yml) layer, which provides the port bindings for the containers in `compose.yml`:

```shell
docker compose \
  -f compose.yml \
  -f overlays/novpn-network.yml \
  up -d
```

If you want to add any overlays, i.e. [`flaresolverr`](./overlays/flaresolverr.yml), just add more `-f overlays/<layer-name>.yml` to the command:

```shell
docker compose \
  -f compose.yml \
  -f overlays/novpn-network.yml \
  -f overlays/flaresolverr.yml \
  up -d
```

### Setup: VPN

The stack supports NordVPN, or generic connections via `gluetun`.

#### Gluetun

There are 2 Gluetun layers included in this stack: [OpenVPN](./overlays/gluetun-openvpn.yml) and [Wireguard](./overlays/gluetun-wireguard.yml). Whichever connection type you choose, you will also need to supply a local network layer, which you can set up by copying the [`example.gluetun-networks.yml` file](./overlays/example.gluetun-networks.yml) to `overlays/gluetun-networks.yml` and editing for your needs.

For OpenVPN connections, drop your `.ovpn` config and whatever other OpenVPN connection files you have in a path in [`apps/gluetun/openvpn/<some-vpn-name>`](./apps/gluetun/). You will mount this path in the `gluetun` container using the `GLUETUN_OPENVPN_DIR` and `GLUETUN_OPENVPN_CONFIG` environment variables.

Set `GLUETUN_OPENVPN_DIR=./apps/gluetun/openvpn/your-vpn-subdir/`, which will mount the VPN config in the `gluetun` container at `/gluetun`. Set `GLUETUN_OPENVPN_CONFIG` to the container's path to your `.ovpn` configuration. For example, if you downloaded a config named `my-username-1.opvn`, and mounted it in the container at `/gluetun`, the config path should be `/gluetun/my-username-1.ovpn`.

If your config looks for other files, it may have a relative path encoded. For example, if your config uses a `.crt` and `.key` file for authentication (recommended), the configuration might have values like `tls-auth ta.key 1` and `ca ca.crt`:

```ovpn
client
dev tun
proto udp
remote 123.456.78.9 1123
resolv-retry infinite
remote-cert-tls server
nobind
persist-key
persist-tun

tls-auth ta.key 1  # relative path to tls auth key
ca ca.crt  # relative path to certificate authority
cert my-username-1.crt  # relative path to certificate
key my-username-1.key  # relative path to cert key

tls-version-min 1.2
cipher AES-256-CBC
auth SHA256
auth-nocache
verb 3
mute 20
```

You will need to change these values so the `gluetun` container can find them. Relative paths don't work, you need to add `/gluetun/` before each value:

```ovpn
...

## Set full path in container to OpenVPN config files

tls-auth /gluetun/ta.key 1
ca /gluetun/ca.crt
cert /gluetun/my-username-1.crt
key /gluetun/my-username-1.key

...
```

Then you can bring the whole stack up with:

```shell
docker compose \
    -f compose.yml \
    -f overlays/flaresolverr.yml \
    -f overlays/gluetun-openvpn.yml \
    -f overlays/gluetun-networks.yml \
    up \
    -d
```

#### NordVPN

*TODO: Write NordVPN setup instructions*
