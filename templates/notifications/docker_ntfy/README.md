# Ntfy <!-- omit in toc -->

Self-hosted push notifications.

## Description <!-- omit in toc -->

Uses PUT/POST methods to send notifications to a custom server.

## Table of Contents <!-- omit in toc -->

- [Setup](#setup)
  - [Docker environment](#docker-environment)
  - [Users](#users)
- [Usage](#usage)
  - [Scripts](#scripts)
  - [User Management](#user-management)
  - [Access Control](#access-control)
    - [ACLs](#acls)
    - [Access tokens](#access-tokens)
- [Links](#links)

## Setup

### Docker environment

- Copy [`.env.example`](./.env.example) -> `.env`
- Edit the `.env` file
  - (optional) Set the `TZ` to your timezone, i.e. `EST` or `PST`
  - Set `NTFY_BASE_URL` to your server's FQDN (i.e. `https://ntfy.your-domain.com`) or IP address (i.e. `http://192.168.1.xxx:<your-ntfy-port>`)
  - If you're using a reverse proxy like NGINX-Proxy-Manager or Traefik, set `NTFY_PROXIED=true`

### Users

After starting the container, you can use the `ntfy` command in the container to manage users.

To create an admin account (you will be prompted for a password):

```shell
docker compose exec -it ntfy ntfy user add --role=admin <your-admin-username>
```

If you need to change a user's password, you can run:

```shell
docker compose exec -it ntfy user change-pass <username>
```

## Usage

### Scripts

There are a number of [`scripts/`](./scripts/) to assist with managing the `ntfy` container. The first time you run this stack, you can use the [`create_admin_user.sh`](./scripts/create_admin_user.sh) script to create the `ntfy` admin user, which has access to all topic.

It is cheap and easy to [create users](./scripts/create_user.sh) and [API tokens](./scripts/create_api_token.sh). You can start simple with a single user you use for everything, and use access tokens to separate feeds, or you can create a new user for each service you connect. The second method is more robust, but can become unwieldy without good notes.

### User Management

To create an admin account (you will be prompted for a password):

```shell
docker compose exec -it ntfy ntfy user add --role=admin <your-admin-username>
```

To create a regular user account:

```shell
docker compose exec -it ntfy ntfy user add <username>
```

If you need to change a user's password, you can run:

```shell
docker compose exec -it ntfy user change-pass <username>
```

To change a user's role:

```shell
docker compose exec -it ntfy user change-role <username> <role>
```

To see your registered users, run:

```shell
docker compose exec -it ntfy user list
```

To delete a user:

```shell
docker compose exec -it ntfy user del <username>
```

### Access Control

#### ACLs

*(ref: https://docs.ntfy.sh/config/#access-control-list-acl)*

To explicitly set a user's permissions on a given topic (a topic must already exist and you can use patterns, i.e. `alerts_*`/`prefix-*`, and the permission must be one of: [`read-write`, `read-only`, `write-only`, `deny`]; you can use `everyone` as a username to apply to all users):

```shell
docker compose exec -it ntfy access <username> <topic> <permission>
```

#### Access tokens

*([ref](https://docs.ntfy.sh/config/#access-tokens))*

To list all tokens:

```shell
docker compose exec -it ntfy ntfy token list
```

To list tokens for a given user:

```shell
docker compose exec -it ntfy ntfy token <username>
```

To add a token for a user:

```shell
docker compose exec -it ntfy ntfy token add <username>
```

To add a token with an expiration:

```shell
docker compose exec -it ntfy ntfy token add --expires=2d <username>
```

To create a token with a label:

```shell
docker compose exec -it ntfy ntfy token add --label="<label-name>" <username>
```

To remove a token from a user:

```shell
docker compose exec -it ntfy ntfy token remove <username> <token>
```

## Links

- [ntfy website](https://ntfy.sh)
- [ntfy Github](https://github.com/binwiederhier/ntfy)
- [ntfy docs](https://docs.ntfy.sh)
  - [ntfy access control](https://docs.ntfy.sh/config/#access-control)
    - [Access control lists (ACL)](https://docs.ntfy.sh/config/#access-control-list-acl)
    - [Access tokens](https://docs.ntfy.sh/config/#access-tokens)
- Setup guides
  - [Medium.com: Ntfy: self-hosted notification service](https://medium.com/@williamdonze/ntfy-self-hosted-notification-service-0f3eada6e657)
  - [(personal blog) Ntfy - Self-hosted push notifications server for all your services](https://akashrajpurohit.com/blog/selfhost-ntfy-for-push-notifications/)
