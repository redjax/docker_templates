# Netdata

## Setup

Setup consists of a Server and an Agent.

### Server

Option 1: Bash script

```shell
#!/bin/bash

docker run -d --name=netdata \
  -p 19999:19999 \
  -v /etc/passwd:/host/etc/passwd:ro \
  -v /etc/group:/host/etc/group:ro \
  -v /proc:/host/proc:ro \
  -v /sys:/host/sys:ro \
  -v /etc/os-release:/host/etc/os-release:ro \
  --cap-add SYS_PTRACE \
  --security-opt apparmor=unconfined \
  netdata/netdata

```

Option 2: Docker Compose

Optionally, edit the `.env` file (copy `.env.example -> .env` if one does not exist) to change container's default values.

From this directory, run `$ docker compsoe up -d`

### Agent

After starting a server, log in and click the `+` button. Copy the `DOCKER` command in "Connect new nodes," then paste it on another machine.

## Notes

## Links

- [Guide: Setup Netdata server with Docker Compose](https://vmnet8.github.io/2020/02/12/Using-docker-compose-yml-to-run-netdata/)
