# Standalone Gitlab Runner

This container can be run on other hosts to connect back to the main [Gitlab server](../compose.yml).

## Usage

First, you need to [create a Gitlab runner](https://docs.gitlab.com/tutorials/create_register_first_runner/#create-and-register-a-project-runner). This will give you an auth token, which you can use to register the runner with the Gitlab server.

Run the command below, replacing `--url https://gitlab.example.com` with your instance URL, `--registration-token "YOUR_REGISTRATION_TOKEN"` with the token you copied during creation in Gitlab, and optionally set a different name with `--description "Your runner's name"`.

```bash
docker run --rm -it -v $(pwd)/config:/etc/gitlab-runner gitlab/gitlab-runner register \
  --non-interactive \
  --url "https://gitlab.example.com" \
  --registration-token "YOUR_REGISTRATION_TOKEN" \
  --executor "docker" \
  --docker-image alpine:latest \
  --description "Standalone runner" \
  --tag-list "helper" \
  --run-untagged="true" \
  --locked="false"

```

You can also use the [`register_runner.sh` script](./scripts/register_runner.sh) to answer prompts to configure your runner.

After registering your runner, (re)start your container with `docker compose restart gitlab-runner`.
