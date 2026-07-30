# HappyDomain

[HappyDomain](https://www.happydomain.org/en/) is a toolbox for managing domains you own.

> [!NOTE]
> As of 2026-07-29, the happyDomain service appears to be broken. The containers start and the webUI is accessible, but clicking on a registrar does nothing. No useful error logs, just nothing happens.

## Setup

- Copy the [example `.env`](.env.example) to `.env`
- If you are testing the container, set `HAPPYDOMAIN_NO_AUTH=1` to disable authentication
- Bring the stack up with `docker compose up -d`
- Navigate to `http://your-ip-or-address:8081`
  - If you changed `HAPPYDOMAIN_HTTP_PORT`, use the port value you set in that env var instead of `:8081`
