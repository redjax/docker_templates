# Docker download suite

## Containers

* Bazarr
   * For subtitle downloads
* Jackett
    * For trackers
* LazyLibrarian
    * eBook downloads (will be replaced with Readarr)
* Readarr
    * eBook downloads
* Sonarr
    * Tv-show downloads
* Radarr
    * Movie downloads
* VPN
    * A VPN container. Using Linuxserver's NordVPN container
* Torrent client options:
    * Deluge
    * Transmission
    * qBittorrent

## Instructions

Note: You should not need to edit the docker-compose.yml file, only the .env file.

1. Clone the repository
2. Copy .env.example to .env
    1. Update env variables, for example adding a download directory for torrents, and specifying an existing media path for the media download containers
3. Run docker-compose up -d