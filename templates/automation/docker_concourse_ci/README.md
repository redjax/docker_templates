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

### Setup Github OAuth

First, [create an OAuth application on Github](https://github.com/settings/applications/new). Copy the client ID and secret, and set them as the following environment variables:

```bash
CONCOURSE_GITHUB_CLIENT_ID=<your oauth client id>
CONCOURSE_GITHUB_CLIENT_SECRET=<your oauth client secret>

## If you're configuring Github Enterprise, set the following too
# CONCOURSE_GITHUB_HOST=github.example.com
# CONCOURSE_GITHUB_CA_CERT=/path/to/ca_cert
```

Users, teams, and organization can be authorized for a Concourse team 1 of 2 ways:

CLI:

```shell
fly set-team -n my-team \
    --github-user my-github-login \
    --github-org my-org \
    --github-team my-other-org:my-team
```

Or pipeline config:

```yaml
roles:
- name: member
  github:
    users: ["my-github-login"]
    orgs: ["my-org"]
    teams: ["my-other-org:my-team"]
```

## Notes

### List CI workers

```shell
fly -t <concourse-target-name> workers
```

### List concourse containers

```shell
fly -t <concourse-target-name> containers
```

### Schedule .yml pipeline job

```shell
fly -t <concourse-target-name> set-pipeline -p <pipeline-name> -c <path/to/pipeline-file.yml>
```

You then need to un-pause the pipeline by logging into the webUI and clicking unpause, or running:

```shell
fly -t <concourse-target-name> unpause-pipeline -p <pipeline-name>
```

Then, trigger the job (use `--watch` to see output in terminal):

```shell
fly -t <concourse-target-name> trigger-job --job demo-hello/hello-job [--watch]
```

## Links

- [How to setup a concourse CI server](https://dev.to/ruanbekker/how-to-setup-a-concourse-ci-server-597g)
- [Github Concourse](https://github.com/concourse/concourse)
- [Concourse Quickstart Guide](https://concourse-ci.org/quick-start.html)
