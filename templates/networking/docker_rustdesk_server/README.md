# Rustdesk Server

Dockerized server for [RustDesk](rustdesk.com)

## Setup

- Copy the [example `.env` file](./.example.env) to `.env` and edit as needed
- Run `docker compose up -d`

## Ports

Rustdesk requires the following ports:

| Port/Range | Proto | Purpose |
| ---------- | ----- | ------- |
| `21114-21119` | TCP | Signal & relay ports, as well as NAT traversal. |
| `21116` | UDP | Signal & relay ports, as well as NAT traversal. |
| `21118` & `21119` | TCP | WebSocket ports for the RustDesk web client. Must use a reverse proxy with HTTPS. |

