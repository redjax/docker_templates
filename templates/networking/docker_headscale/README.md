# Headscale

Self-hosted implementation of the Tailscale control plane.

## Setup

- On a fresh clone:
  - Copy `headscale/config/headscale_config.example.yaml` -> `headscale/config/config.yaml`
    - Edit the `config.yaml` file:
      - Edit `server_url`, set your `headscale` address
      - Edit `listen_addr`, uncomment the line under `# For production:` and comment the line beneath with `127.0.0.1:8080`
      - Do the same with `grpc_listen_addr`
  - Copy `.env.example` -> `.env`
    - (Optional) modify the HTTP/HTTPS ports the services run on
  - Bring up the stack with `docker compose up -d`
    - Once the stack is running, run the scripts in [`scripts/`](./scripts/) in the following order:
      - `./scripts/create-headscale-namespace.sh`: Create your Headscale namespace. This is like an account for Tailscale.
      - `./scripts/create-headscale-user.sh`: Create the initial Headscale user.
      - `./scripts/create-headscale-apikeys.sh`: Create the API key for Headscale-UI.
  - Configure your reverse proxy, cloudflare, etc
  - Navigate to your `headscale-ui` address
    - 

## Notes

- This template contains 2 images: `headscale` and `headscale-ui`
  - `headscale` on its own serves instructions for setup, i.e. at `/windows` for Windows setup, but it does not show you a control plane.
  - A 3rd-party `headscale-ui` container serves the control plane.
  - These containers exist on the same network so they can be referenced by container hostname.
  - Forwarding both ports seems to be necessary, and I had to create 2 entries in my reverse proxy, `headscale.domain.com` and `headscale-ui.domain.com`.

## Links

- [Headscale Github](https://github.com/juanfont/headscale)
- [Headscale setup guide](https://headscale.net/setup/install/container/#configure-and-run-headscale)
- [Techdox: Headscale](https://docs.techdox.nz/headscale/)
