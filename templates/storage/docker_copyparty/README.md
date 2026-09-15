# Copyparty

[Copyparty](https://copyparty.eu/) is a portable file server loaded with features and support for many protocols.

## Setup

- Copy [example `.env` file](./.env.example) to `.env`
  - Optionally change any defaults, i.e. the `COPYPARTY_HTTP_PORT`
- Copy [an example config file](./examples/config/) into the [`config/` directory](./config/) and name it `copyparty.conf`.
  - You can use the [`00-example-full.conf` file](./examples/config/00-example-full.conf) as a reference for [Copyparty's options](https://github.com/9001/copyparty/tree/hovudstraum#server-config)
- Run `docker compose up -d`
