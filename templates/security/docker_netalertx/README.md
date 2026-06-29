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

