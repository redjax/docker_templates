# Tangled Knot

[Knot](https://tangled.org/tangled.org/knot-docker/) is a self-hosted instance of [Tangled](https://tangled.org/) is a federated Git forge built on the [AT protocol](https://atproto.com/).

## Setup

This compose stack pulls containers from the [AT container registry](https://atcr.io). You must login to this repository using `docker login` before you can pull images. You can use your tngl.sh username, the same one you log into [tangled](https://tangled.org) with.

Before pulling the containers, run:

```shell
docker login atcr.io
```

When prompted for a username/password, enter your handle, i.e. `username.tngl.sh` and password.

