# Kiwix Server

Offline .zim file browser for sites like Wikipedia & StackOverflow.

## Description

Dockerized [Kiwix server](https://github.com/kiwix/kiwix-tools), which can serve .zim files like the entirety of Wikipedia. Downloads these sites for offline access & serve them with Kiwix.

## Customize your own Kiwix server

- [Example kiwix Dockerfile](https://github.com/kiwix/kiwix-tools/blob/main/docker/server/Dockerfile)

## Where to find .zims for Kiwix Server

.zim files should be placed in the Kiwix data directory (defined in the env variable `KIWIX_DATA_DIR`). They can be downloaded as a torrent, or with `wget`. When using `wget`, add a `-c` to allow the download to be canceled and resumed, i.e. `wget -c <https://example.com/your-zim-file.zim>`.

- [Kiwix Library](https://library.kiwix.org/)
- [Kiwix .zim FTP directory](https://download.kiwix.org/zim/)

## Fix Permission Errors in Containers

The containers run with `PUID` and `PGID` `=1000`. This means if you let the container create volume mounts on the host, they will be owned by root and you will get permission errors in the container.

Before running any of the containers in this stack, create any host volume mounts (if you modified these in your `.env`), and use `chown -R 1000:1000 $HOST_VOLUME`, where `$HOST_VOLUME` is your path.

For example, if you change `TRANSMISSION_CONFIG_DIR`, before running the container you should run `mkdir -pv data/transmission/config` and `chown -R 1000:1000 data/transmission/config`.
