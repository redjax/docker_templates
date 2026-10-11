# Authentik <!-- omit in toc -->

[Authentik](https://goauthentik.io/) is an open source identity provider.

## Table of Contents <!-- omit in toc -->

- [Setup](#setup)
  - [Create a User](#create-a-user)
  - [Create Groups](#create-groups)
  - [Setup Email Notifications](#setup-email-notifications)
- [Applications and Providers](#applications-and-providers)
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

> [!NOTE]
> You should add MFA to your accounts as soon as possible after creating them.

### Create Groups

You can use groups to provide standardized access rules to a range of users/service accounts. You might make a group named `admins`, and create a special `username.admin` version of your account with admin privileges so you aren't logging into the root user, or `homelab` to group homelab service accounts and users.

### Setup Email Notifications

Authentik supports [SMTP for email notifications and alerts](https://docs.goauthentik.io/install-config/email/). You can use a free SMTP server like Gmail to send emails from the Authentik server to users defined in one of the various email stages.

Edit the `.env` file's `AUTHENTIK_SMTP_*` variables with your server's settings. Some servers I've used:

- Gmail

  | Variable                   | Example Value                  |
  | -------------------------- | ------------------------------ |
  | `AUTHENTIK_SMTP_HOST`      | `smtp.gmail.com`               |
  | `AUTHENTIK_SMTP_PORT`      | `587` (TLS) / `465` (SSL)      |
  | `AUTHENTIK_SMTP_USERNAME`  | `username@gmail.com`           |
  | `AUTHENTIK_SMTP_PASSWORD`  | `<your-gmail-app-password>`    |
  | `AUTHENTIK_SMTP_USE_TLS`   | `true`                         |
  | `AUTHENTIK_SMTP_USE_SSL`   | `false`                        |
  | `AUTHENTIK_SMTP_TIMEOUT`   | `10`                           |
  | `AUTHENTIK_SMTP_FROM_ADDR` | `mydomain.authentik@gmail.com` |

- Fastmail

  | Variable                   | Example Value                     |
  | -------------------------- | --------------------------------- |
  | `AUTHENTIK_SMTP_HOST`      | `smtp.fastmail.com`               |
  | `AUTHENTIK_SMTP_PORT`      | `587` (TLS) / `465` (SSL)         |
  | `AUTHENTIK_SMTP_USERNAME`  | `username@fastmail.com`           |
  | `AUTHENTIK_SMTP_PASSWORD`  | `<your-fastmail-app-password>`    |
  | `AUTHENTIK_SMTP_USE_TLS`   | `true`                            |
  | `AUTHENTIK_SMTP_USE_SSL`   | `false`                           |
  | `AUTHENTIK_SMTP_TIMEOUT`   | `10`                              |
  | `AUTHENTIK_SMTP_FROM_ADDR` | `mydomain.authentik@fastmail.com` |

## Applications and Providers

In Authentik, an [application](https://docs.goauthentik.io/add-secure-apps/applications/) represents a thing you're protecting, i.e. "Grafana" or "Jellyfin."

A [provider](https://docs.goauthentik.io/add-secure-apps/providers/) describes how Authentik talks to that application. Authentik supports several providers, including [OIDC/OAuth2](https://docs.goauthentik.io/add-secure-apps/providers/oauth2/), [SAML](https://docs.goauthentik.io/add-secure-apps/providers/saml/), and [LDAP](https://docs.goauthentik.io/add-secure-apps/providers/ldap/).

You could also sync your users to a cloud idP like [Microsoft Entra](https://docs.goauthentik.io/add-secure-apps/providers/entra/) or [Google Workspace](https://docs.goauthentik.io/add-secure-apps/providers/gws/).

## Links

- [Authentik home](https://goauthentik.io)
- [Authentik Github](https://github.com/goauthentik/authentik)
- [Authentik docs](https://docs.goauthentik.io)
  - [First steps](https://docs.goauthentik.io/install-config/first-steps/)
  - [Upgrade docs](https://docs.goauthentik.io/install-config/upgrade/)
  - [Email setup](https://docs.goauthentik.io/install-config/email/)
  - [High Availability](https://docs.goauthentik.io/install-config/high-availability/)
  - [Applications](https://docs.goauthentik.io/add-secure-apps/applications/)
  - [Providers](https://docs.goauthentik.io/add-secure-apps/providers/)
  - [Flows](https://docs.goauthentik.io/add-secure-apps/flows-stages/flow/)
  - [Stages](https://docs.goauthentik.io/add-secure-apps/flows-stages/stages/)
  - [Authentik policy docs](https://docs.goauthentik.io/customize/policies/)
  - [Docker Outposts](https://docs.goauthentik.io/add-secure-apps/outposts/)
  - [Blueprints/templates](https://docs.goauthentik.io/customize/blueprints/)
