# Domain Locker

[Domain Locker](https://github.com/lissy93/domain-locker) is a tool for keeping track of your domain names.

## Setup

- Copy the [example `.env`] to `.env`
- Edit the file
  - Optionally, change the `DL_APP_PORT` environment variable to run the app on a port other than the default `3000`
  - If you have a [dnsdumpster account](https://dnsdumpster.com/), paste your API key in `DNS_DUMPSTER_TOKEN` to aid with DNS lookups
- Run the stack with `docker compose up -d`
- Visit the webUI at `http://your-ip-or-hostname:3000`
  - If you set a different port for `DL_APP_PORT`, use that one instead of `:3000`
