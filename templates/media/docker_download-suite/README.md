# Docker download suite <!-- omit in toc -->

*Arr stack with networking configurations. Supports binding ports straight to the host, or through a VPN using `gluetun` (OpenVPN and Wireguard supported).

## Table of Contents <!-- omit in toc -->

- [Containers](#containers)
- [Setup](#setup)
  - [Setup: Host Networking, No VPN](#setup-host-networking-no-vpn)
  - [Setup: VPN](#setup-vpn)
    - [Gluetun](#gluetun)
    - [NordVPN](#nordvpn)
- [Manage Script](#manage-script)

## Containers

- Bazarr: For subtitle downloads
- Jackett: For torrent indexers
- Prowlarr: For torrent indexers (newer than Jackett)
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

> [!NOTE]
> When using Gluetun, you may need to add your seedbox's IP in CIDR format, like `FIREWALL_OUTBOUND_SUBNETS=203.0.113.42/32`. If you are able to find the remote's VPN IP, it is better to use that. If you can SSH into the remote and run `ip addr show tun0`, you might be able to find the server's VPN IP.

[Gluetun](https://github.com/passteque/gluetun) is a VPN client that can connect to both OpenVPN and Wireguard servers. It runs in a Docker container and can connect services to each other. In this download suite, Gluetun allows container like Sonarr and Radarr to talk to Jackett, but directs all Jackett and torrent client traffic through the Gluetun container. If you rent a seedbox that offers a VPN client, you can use this container to route ALL of your traffic (besides the Sonnar/Radarr/etc webUI) through the seedbox. Communication between Radarr and Sonarr is limited to the container network, keeping requests internal.

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

## Manage Script

The [`manage-stack.sh` script](./scripts/manage-stack.sh) generates `docker compose -f compose.yml -f ... <operation>` commands based on your input. The `compose_files` array is my "default" stack, and this script helps to run common operations without having to type the full `docker compose` command  each time.

Run `./scripts/manage-stack.sh -h` to see its usage. Quick reference:

| Command                                                 | Description                                                          |
| ------------------------------------------------------- | -------------------------------------------------------------------- |
| `./scripts/manage-stack.sh -o start`                    | Brings the stack up                                                  |
| `./scripts/manage-stack.sh -o stop`                     | Brings the stack down                                                |
| `./scripts/manage-stack.sh -o restart`                  | Bring the stack down fully, then back up                             |
| `./scripts/manage-stack.sh -o update`                   | Do a `docker compose pull`, bring the stack down fully, then back up |
| `./scripts/manage-stack.sh -o logs -n <container-name>` | Tail the logs for a container running in the stack                   |
