# Mindwtr PWA

This Compose stack hosts the [Mindwtr PWA](), a webapp that can connect to the central cloud server and act as the webUI for your Mindwtr instance.

## Setup

- Copy the [example `.env` file](./.env.example) to `.env`
- Set `MINDWTR_CLOUD_URL` to the URL you access the Cloud server at.
  - For example, `https://sync.example.com` or `http://192.168.1.100:8787`
- Run `docker compose up -d`

Make sure your Mindwtr Cloud's `.env` file has `MINDWTR_CLOUD_CORS_ORIGIN` set to the URL you access the PWA from, i.e. `https://tasks.example.com` or `http://192.168.1.100:5173`.

In the webUI, navigate to Settings > Sync and choose "Self-hosted" for the sync backend. Use your Mindwtr Cloud's `MINDWTR_CLOUD_AUTH_TOKENS` value as the access token.

