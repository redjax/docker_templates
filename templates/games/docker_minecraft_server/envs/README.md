# Env files

You can pass one of these file's to a container's `env_file:`, which will override anything you've set in the container's `environment:` with the values in the `env_file`.

For example, say you have a container like this:

```yaml
---
services:
  container-name:
    image: user/container:tag
    restart: unless-stopped
    environment:
        LOG_LEVEL: ${APP_LOG_LEVEL:-INFO}
        AUTO_RELOAD: ${APP_AUTO_RELOAD:-false}
        TZ: ${TZ:-Etc/UTC}
```

The values in `environment:` will be passed into the container as environment variables. The `:-` syntax in the variable declaration sets a default value; this value will be used if no other value is detected in the host's  environment or in your `.env` file.

Another way to write the container service above is to use `env_file:` instead of `environment:`, and pass a file with your environment variables.

```yaml
---
services:
  container-name:
    image: user/container:tag
    restart: unless-stopped
    env_file:
      - ./envs/dev.env
    ## When using env_file, you don't need an environments: section
    # environment:
    #   LOG_LEVEL: ${APP_LOG_LEVEL:-INFO}
    #   ...
```

This container looks in a path (relative to the `compose.yml` file) `./envs` for a file named `dev.env`, which should look like:

```text
## ./envs/dev.env
LOG_LEVEL=INFO
AUTO_RELOAD=false
TZ=Etc/UTC
```

Note that these values are the same as the defaults (the `${VAR_NAME:-default value}` syntax). When passing an `env_file:`, you don't use the `${VARIABLE_SUBSTITUTION}` syntax. This is because when passing an `env_file`, you are telling the container exactly which values to use and do not need to leave it up to defaults.

Using this method, you could create different `compose.yml` files, like `dev.compose.yml`, `ci.compose.yml`, `compose.yml` (the "main"/production stack), and use different `env_files` for each environment.
