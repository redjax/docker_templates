# HappyDomain

[HappyDomain](https://www.happydomain.org/en/) is a toolbox for managing domains you own.

> [!NOTE]
> The `compose.yml` is for smaller scale/personal deployments. See the [`largescale_deployment/` directory](./largescale_deployment/) for a "production ready" version that deploys the individual checker containers.
>
> This personal-scale version still runs the checkers, but bundled in a single container image. This is plenty for most users.

## Setup

- Copy the [example `.env`](.env.example) to `.env`
- If you are testing the container, set `HAPPYDOMAIN_NO_AUTH=1` to disable authentication
- Bring the stack up with `docker compose up -d`
- Navigate to `http://your-ip-or-address:8081`
  - If you changed `HAPPYDOMAIN_HTTP_PORT`, use the port value you set in that env var instead of `:8081`
