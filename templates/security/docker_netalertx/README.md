# NetAlertX

Network intruder & presence detector.

## Setup

- Check the latest version of the [`netalertx/netalertx` container](https://github.com/netalertx/NetAlertX/pkgs/container/netalertx).
- Copy [the example `.env` file](./.env.example) to `.env`
  - Set `NETALERT_TIMG_TAG` to the latest version number
  - (Optional) Set a host path for the `NETALERTX_DATA_DIR` mount path
  - Set your timezone in `TZ`
- Run `docker compose up -d`
- Navigate to `http(s)://your-host-or-ip:20211` to load the webUI
  - If you changed the value of `NETALERTX_PORT`, use that port number instead of `20211`

## Configure

Netalertx is configured via the webUI. Read the [Netalertx docs](https://docs.netalertx.com) for all available configurations.

### Configure interfaces

- Find your main interface with `ip route get 1.1.1.1`. Example values: `enp2s0`, `enp6s0`, `eth0`
  - To list all interfaces, use `ip link show`
- Find your LAN subnet (i.e. `192.168.1.0/24`) with `ip addr`
- In the [`.env` file](./.env.example), set `NETALERTX_SCAN_SUBNETS=192.168.1.0/24 --interface=eth0`
- Edit `/etc/systctl.d/99-netalertx.conf` and add the following lines:

  ```conf
  ## Docker Netalertx sysctl
  net.ipv4.conf.all.arp_ignore=1
  net.ipv4.conf.all.arp_announce=2
  ```

- Reload `sysctl` with `sudo sysctl --system`

> [!NOTE]
> Sometimes `NETALERTX_SCAN_SUBNETS` doesn't work. Open the settings in the webUI and look for `Networks to scan`, and make sure you only see the subnet you want to scan, i.e. `192.168.1.0/24 --interface=enp2s0`.
>
> If you see additional subnets, click the "Remove all" button, then manually add just the 1 interface back.
>
> If the settings page appears to freeze after clicking the Save button, restart the container with `docker compose up -d`. Your settings should be saved and the container will begin using the newly applied settings.
