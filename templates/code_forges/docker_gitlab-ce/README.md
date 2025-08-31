# Gitlab Community Edition <!-- omit in toc -->

Self-hosted Gitlab server & runner.

## Table of Contents <!-- omit in toc -->

- [Requirements](#requirements)
- [Omnibus Configuration](#omnibus-configuration)
- [Troubleshooting](#troubleshooting)
  - [Container permission errors](#container-permission-errors)
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

[List of Gitlab omnibus config optionss](https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/README.md)

## Troubleshooting

### Container permission errors

If this container fails to start due to permission problems try to fix it by executing:

```bash
docker exec -it gitlab update-permissions
docker restart gitlab
```

## Links

- [Gitlab docs](https://docs.gitlab.com/)
  - [Gitlab Docker install docs](https://docs.gitlab.com/install/docker/)
    -[Gitlab Docker backup docs](https://docs.gitlab.com/install/docker/backup/)