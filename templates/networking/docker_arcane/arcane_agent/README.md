# Arcane Agent

Arcane [remote environment managent](https://getarcane.app/docs/remote/environments) agent.

## Setup

> [!NOTE]
> You must use at least one of the [network overlays](./overlays/), but you cannot use both at the same time.
>
> - The [`direct.yml` layer](./overlays/direct.yml) is for machines that connect directly to the server, i.e. on the same VPN or LAN.
> - The [`edge.yml` layer](./overlays/edge.yml) sends outbound traffic to the server, and does not require a published port. It's good for devices on other networks, like a VPS.

- Copy [example `.env`](./.env.example) to `.env`
- Choose a [network layer](./overlays/)
  - When using the [`edge.yml` layer](./overlays/edge.yml), you must set a transport value in `ARCANE_EDGE_TRANSPORT`. The options are:
    - `poll`: Checks in periodically. The first action after an idle period may take a moment.
    - `auto`: Maintains a continuous tunnel, preferring gRPC and falling back to WebSocket.
    - `websocket`: Maintains a continuous WebSocket tunnel.
    - `grpc`: Maintains a continuous gRPC tunnel with no WebSocket fallback.
