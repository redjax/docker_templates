# Concourse CI

[Concourse](https://concourse-ci.org) is an open-source, self-hostable CI platform. It refers to itself as a "continuous thing-doer."

## Setup

- Copy [`.env.example`](./.env.example) -> `.env`
- Run [`./scripts/generate_secrets.sh`](./scripts/generate_secrets.sh)
    - This will generate secret values, which you should paste into the `.env` file
- Fill out any other values in `.env`, then run `docker compose up -d`
- Once the Concourse server is up and running, run [`./scripts/install_fly_cli.sh`](./scripts/install_fly_cli.sh) to install the `fly` CLI utility
- Register your Concourse server with `fly` using:

```shell
fly login -c http://<concourse-url-or-ip>:<concourse-port> -t <councourse target>
```

- The login command will show you a URL, which you should click
    - On the page that opens, copy the bearer key and paste it into the CLI
    - If you can't copy/paste, you can type the token in manually
- Check your `fly` targets with `fly targets`

## Notes
