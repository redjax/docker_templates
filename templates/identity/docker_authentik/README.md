# Authentik <!-- omit in toc -->

[Authentik](https://goauthentik.io/) is an open source identity provider.

## Table of Contents <!-- omit in toc -->

- [Setup](#setup)
  - [Create a User](#create-a-user)
  - [Create Groups](#create-groups)
- [Links](#links)

## Setup

- Copy the [example `.env` file](./.env.example) to `.env`
  - Edit values to your liking, i.e. changing HTTP/HTTPS ports or volume mounts
  - For any `*_IMG_TAG` variable, make sure to check the most recent tag using the link above the env var.
- Generate secrets with [`./generate-secrets.sh`](./generate-secrets.sh)
  - Copy the values the script outputs into your `.env`
- Run `docker compose up -d`

Authentik will be available at your server's IP on the port you set in `AUTHENTIK_HTTP_PORT`, or via HTTPS using the `AUTHENTIK_HTTPS_PORT`. For example: `http(s)://<ip-or-hostname>:$AUTHENTIK_PORT`.

The first time you load Authentik, you will be guided through setting up an admin user.

Authentik provides a ["first steps" documentation page](https://docs.goauthentik.io/install-config/first-steps/) to help guide you through the first setup.

### Create a User

Log into the Authentik admin panel by clicking the "Admin interface" button in the top right of the screen. You should create a new, non-admin user that you will authenticate as.

Go to `Directory > Users` and click "New User." It is ok to leave the user with no groups at first, until you [create them](#create-groups).

### Create Groups

You can use groups to provide standardized access rules to a range of users/service accounts. You might make a group named `admins`, and create a special `username.admin` version of your account with admin privileges so you aren't logging into the root user, or `homelab` to group homelab service accounts and users.

## Links

- [Authentik home](https://goauthentik.io)
- [Authentik Github](https://github.com/goauthentik/authentik)

