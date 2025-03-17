# Semaphore

Semaphore automation platform.

## Description

A UI for Ansible, Terraform/OpenTofu, Powershell, & more.

## Instructions

- Copy [`.env.example`](./.env.example) to `.env`
  - Edit to your liking, but note that you **must set a value for `SEMAPHORE_ACCESS_KEY`**.
  - You can generate a key by running `head -c32 /dev/urandom | base64`, or by using the [`generate_semaphore_access_key.sh` script](./generate_semaphore_access_key.sh).
- Run `docker compose up -d`
- Visit your web UI at `https://your-server-ip-or-hostname:3000` and log in with your admin username and password
  - If you changed the value of `SEMAPHORE_WEBUI_PORT`, use that port instead of `:3000`

## Links

- [Docker Hub: Sempahore](https://hub.docker.com/r/semaphoreui/semaphore)
- [Github: Semaphore](https://github.com/semaphoreui/semaphore)
- [Semaphore docs: Docker install](https://docs.semaphoreui.com/administration-guide/installation/docker/)
