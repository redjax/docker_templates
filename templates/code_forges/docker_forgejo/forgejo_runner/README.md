# Forgejo Runner

Container image for a [Forgejo Actions runner](https://forgejo.org/docs/latest/admin/actions/).

[Forgejo runner releases](https://code.forgejo.org/forgejo/runner/tags).

## Setup

- Copy the [example `config.yml`](./examples/example.runner-config.yml) to `config/runner-config.yml`.
- Log into Forgejo as an admin and go to site administration > Actions > Runers.
- Create a new runner, give it a name, and copy the `server:` block, then save the new runner.
- Paste the copied `server:` block at the bottom of the `config/runner-config.yml` file you create.
- Run `docker compose up -d`
