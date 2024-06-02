# Docker_Plex

Instructions: Clone repository, copy .env.example to a new .env file. (Optional) change .env variables for storage (i.e. add a path to media folders for Plex), then run docker-compose up -d.

By default, this will create 3 containers:

* Plex server
* [Kitana](https://github.com/pannal/Kitana) (for loading plugins)
* [Tautulli](https://tautulli.com) (for Plex server stats)

Kitana and Tautulli are optional and can be disabled by commenting the service sections in docker-compose.yml.

## First run
The compose file will create folders for each service's configuration. You can access Plex and Tautulli like:

* Plex: http://\<server-ip\>:32400
* Tautulli: http://\<server-ip\>:8181
    * This can be overridden by changing the value of TAUTULLI_WEB_PORT= in .env

## Manually install Plex plugins
* Download plugin zip
* Copy into Plex>Library>Application Support>Plex Media Server>Plug-ins
    * If you specified another location for the Plex config directory in .env file (PLEX_CONF_DIR=), use that directory instead of "Plex" specified above
* Unzip plugin and delete .zip file
* Restart compose stack (docker-compose up -d)