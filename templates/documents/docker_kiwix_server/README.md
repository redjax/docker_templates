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
