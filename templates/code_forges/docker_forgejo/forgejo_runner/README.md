# Forgejo Runner

Container image for a [Forgejo Actions runner](https://forgejo.org/docs/latest/admin/actions/).

[Forgejo runner releases](https://code.forgejo.org/forgejo/runner/tags).

## Setup

- Copy the [example `config.yml`](./examples/example.runner-config.yml) to `config/runner-config.yml`.
- Log into Forgejo as an admin and go to site administration > Actions > Runers.
- Create a new runner, give it a name, and copy the `server:` block, then save the new runner.
- Paste the copied `server:` block at the bottom of the `config/runner-config.yml` file you create.
- Run `docker compose up -d`

## Troubleshooting

### Clear pipeline runner cache

Clear the cache by stopping the runner container and deleting its cache directory. By default, this is a Docker volume named `forgejo-runner_cache`.

```shell
docker compose down
docker volume rm forgejo-runner_cache
docker compose up -
```

If you used a host volume for `FORGEJO_RUNNER_CACHE_DIR` in the [`.env` file](./.env.example), i.e. `./cache`, just remove that directory.

```shell
rm -rf $FORGEJO_RUNNER_CACHE_DIR
```

