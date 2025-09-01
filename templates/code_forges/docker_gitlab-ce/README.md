# Gitlab Community Edition <!-- omit in toc -->

Self-hosted Gitlab server & runner.

## Table of Contents <!-- omit in toc -->

- [Requirements](#requirements)
- [Omnibus Configuration](#omnibus-configuration)
- [Troubleshooting](#troubleshooting)
  - [Container permission errors](#container-permission-errors)
- [Cloudflare Setup](#cloudflare-setup)
- [Setup Docker Registry](#setup-docker-registry)
- [Links](#links)

## Requirements

🔗 [Gitlab System Requirements](https://docs.gitlab.com/install/requirements/)

Quick Specs:

| Resource | Minimum                                                                                                                                | Recommended                                                                                            |
| -------- | -------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| Storage  | 2.5 GB                                                                                                                                 | `NA`                                                                                                   |
| CPU      | 8 vCPU (20 requests per second *or* 1,000 users)                                                                                       | [Gitlab docs: reference architecture](https://docs.gitlab.com/administration/reference_architectures/) |
| Memory   | 8 GB (see ['running Gitlab in a memory-constrained environment](https://docs.gitlab.com/omnibus/settings/memory_constrained_envs.html) | 16 GB (20 requessts/second or 1,000 users)                                                             |
| Database | [PostgreSQL requirements](https://docs.gitlab.com/install/requirements/#postgresql)                                                    | `NA` (postgres is required)                                                                            |
| Redis    | [Redis requirements](https://docs.gitlab.com/install/requirements/#redis)                                                              | `NA` (postgres is required)                                                                            |

## Omnibus Configuration

[List of Gitlab omnibus config options](https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/README.md)

Much of Gitlab's configuration is done using the `GITLAB_OMNIBUS_CONFIG` environment variable. This can become difficult to work with in the `compose.yml` file, so instead, this setup uses a [`gitlab.env` file](./example.gitlab.env). The [`compose.yml` stack](./compose.yml) looks for `gitlab.env` in the current directory and loads the `GITLAB_OMNIBUS_CONFIG` from there.

Before running this container, copy `example.gitlab.env` -> `gitlab.env` and review the configuration options.

## Troubleshooting

### Container permission errors

If this container fails to start due to permission problems try to fix it by executing:

```bash
docker exec -it gitlab update-permissions
docker restart gitlab
```

## Cloudflare Setup

> [!WARNING]
> This setup may not work for your needs. If you use Cloudflare and a proxy like Pangolin,
> you may need a second domain just for SSH. Cloudflare cannot proxy SSH connections,
> so you would serve Gitlab's web UI over your primary domain, and SSH over the second, un-proxied domain.
>
> This setup requires port forwarding on your home router, and requires ports `80` and `443` to be forwarded
> to the server hosting Gitlab.

Assumptions:

- You have a domain name, and you've set its nameservers to Cloudflare.
- You have a machine on your LAN running Gitlab, with [the Traefik overlay](./overlays/traefik.yml)
  - To run the stack with Traefik, use `docker compose -f compose.yml -f overlays/traefik.yml up -d`
- Ports `80` and `443` are bound to Traefik, so if you have any other router forwarding to a different machine's `80` or `443`, this won't work.

For the sake of this document, `gitlab.domain.com` is the example domain name. Replace `domain.com` with your domain.

In Cloudflare's DNS, create the following entries:

| Record Type | Name | Content | Proxy Status | Notes |
| ----------- | ---- | ------- | ------------ | ----- |
| `A` | `git` | Your [public IP address](https://www.ipadr.is) | Proxied (orange cloud) | |
| `A` | `gitlab` | Your [public IP address](https://www.ipadr.is) | Proxied (orange cloud) | |
| `A` | `domain.com` | [public IP address](https://www.ipadr.is) | Not proxied (gray cloud) | |

Replace `domain.com` with your domain, and set your [public IP address](https://www.ipadr.is) in the Content field. It is very important to leave the root `domain.com` A record un-proxied.

Edit your [`gitlab.env` file](./env_files/example.gitlab.env). Edit the `GITLAB_OMNIBUS_CONFIG` variable, setting `gitlab_rails['gitlab_ssh_host'] = 'domain.com'`.

Edit your [Traefik `dynamic_config.yml`](./config/traefik/example.dynamic_config.yml), setting the router rule to:
```yaml
rule: "Host(`gitlab.ingit.dev`)"
```

If you create an entry in your `~/.ssh/config`, make sure to use the right port (whatever you set for `GITLAB_SSH_PORT` in the [Gitlab `.env` file](./.env.example)).

```plaintext
## ~/.ssh/config
Host domain.com
  HostName domain.com
  User git
  Port 222
  ## You must create this file and upload it to Gitlab, i.e.
  #    ssh-keygen -t rsa -b 4096 -f ~/.ssh/gitlab_id_rsa -N ""
  IdentityFile ~/.ssh/gitlab_id_rsa
```

## Setup Docker Registry

To enable the Docker registry feature of Gitlab, you have to set the following configurations:

```rb
gitlab_rails['registry_enabled'] = true;
registry['enable'] = true;
registry_external_url 'https://registry.ingit.dev';
gitlab_rails['registry_host'] = 'registry.ingit.dev';
registry_nginx['enable'] = false;
registry['registry_http_addr'] = '127.0.0.1:5000';
```

Edit the [Gitlab env file](./env_files/example.gitlab.env). Add the following to the `GITLAB_OMNIBUS_CONFIG` (or change the settings):

```plaintext
GITLAB_OMNIBUS_CONFIG="gitlab_rails['registry_enabled'] = true; registry['enable'] = true; registry_external_url 'https://registry.example.com'; gitlab_rails['registry_host'] = 'registry.example.com'; registry_nginx['enable'] = false; registry['registry_http_addr'] = '127.0.0.1:5000'"
```

Note that these configurations must all be on 1 line, separated by a semicolon and a space (`; `).

If you are [using Cloudflare](#cloudflare-setup), also add an un-proxied (gray icon) `A` name entry for `registry`, pointed to [your public IP address](https://ipadr.is).

Don't forget to uncomment the registry portions of the [dynamic Traefik config](./config/traefik/dynamic_config.yml) and the [regular Traefik config](./config/traefik/traefik_config.yml).

## Links

- [Gitlab docs](https://docs.gitlab.com/)
  - [Gitlab Docker install docs](https://docs.gitlab.com/install/docker/)
    -[Gitlab Docker backup docs](https://docs.gitlab.com/install/docker/backup/)