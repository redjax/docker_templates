# Semaphore

Semaphore automation platform.

## Description

A UI for Ansible, Terraform/OpenTofu, Powershell, & more.

## Instructions

- Copy [`.env.example`](./.env.example) to `.env`
  - Edit to your liking, but note that you **must set a value for `SEMAPHORE_ACCESS_KEY`**.
  - You can generate a key by running `head -c32 /dev/urandom | base64`, or by using the [`generate_semaphore_access_key.sh` script](./generate_semaphore_access_key.sh).
- Run the appropriate `docker compose up` command, based on the database you want to use. You **must** run one of these to start a database locally. If you are using an external database, you can just use `docker compose up -d`.
  - For MySQL: `docker compose -f compose.yml -f overlays/mysql.yml up -d`
  - For Postgres: `docker compose -f compose.yml -f overlays/postgres.yml up -d`
- Visit your web UI at `https://your-server-ip-or-hostname:3000` and log in with your admin username and password
  - If you changed the value of `SEMAPHORE_WEBUI_PORT`, use that port instead of `:3000`

> [!NOTE]
> You can also use the [`docker_cmd.sh` script](./scripts/docker_cmd.sh) to run Docker operations. The script accepts args like `--db postgres` and `-o [start|stop|restart|logs <service-name>]`, and will concatenate your options into a `docker compose` command. This is purely a convenience, you can just as easily run the commands by hand.
>
> Run `./scripts/docker_cmd.sh -h` for the help menu.

## Links

- [Docker Hub: Sempahore](https://hub.docker.com/r/semaphoreui/semaphore)
- [Github: Semaphore](https://github.com/semaphoreui/semaphore)
- [Semaphore docs: Docker install](https://docs.semaphoreui.com/administration-guide/installation/docker/)
