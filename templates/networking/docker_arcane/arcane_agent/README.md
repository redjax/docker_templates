# Arcane Agent

Arcane [remote environment managent](https://getarcane.app/docs/remote/environments) agent.

## Setup

> [!NOTE]
> You must use at least one of the [network overlays](./overlays/), but you cannot use both at the same time.
>
> - The [`direct.yml` layer](./overlays/direct.yml) is for machines that connect directly to the server, i.e. on the same VPN or LAN.
> - The [`edge.yml` layer](./overlays/edge.yml) sends outbound traffic to the server, and does not require a published port. It's good for devices on other networks, like a VPS.

- Copy [example `.env`](./.env.example) to `.env`
- Add an agent in the Arcane admin UI
  - Generate a pairing token and paste it into `ARCANE_AGENT_TOKEN`
- Set the URL to your Arcane server in `ARCANE_MANAGER_URL`
  - Example URLs:
    - `https://arcane.example.com`
    - `http://192.168.1.7:3833`
