# Templates Map

Map of the repository's template categories. This page is automatically rendered by the [`update_repo_map.py` script](../scripts/update_repo_map.py)

## Table of Contents

- [Map](#map)
  - Categories in the [templates directory](../templates)
- [All Templates](#all-templates)
  - Full listing of all categories & the templates within
  - Note: some templates do not include a `compose.yml` or `.env.example` file, and are not picked up by the `update_repo_map.py` script, i.e. the [`netdata` stack](../templates/monitoring_alerting/docker_netdata).
  - At a later date I will rework this by including a file indicator for categories (`.category`) and templates (`.docker.template`, `.cookiecutter.template`, etc)

## Map

### Template Categories

- [dashboards](../templates/dashboards)
- [llm](../templates/llm)
- [backup](../templates/backup)
- [games](../templates/games)
- [monitoring_alerting](../templates/monitoring_alerting)
    - [docker_netdata](../templates/monitoring_alerting/docker_netdata) 
- [automation](../templates/automation)
- [rss](../templates/rss)
- [bots](../templates/bots)
- [web_scraping](../templates/web_scraping)
- [security](../templates/security)
    - [docker_wazuh](../templates/security/docker_wazuh) 
- [messaging](../templates/messaging)
- [database](../templates/database)
    - [web_uis](../templates/database/web_uis) 
- [code_forges](../templates/code_forges)
    - [docker_drone](../templates/code_forges/docker_drone) 
- [notifications](../templates/notifications)
- [misc](../templates/misc)
    - [project_templates](../templates/misc/project_templates)
        - [docker_wordpress-nginx](../templates/misc/project_templates/docker_wordpress-nginx)  
- [file_transfer](../templates/file_transfer)
- [media](../templates/media)
- [storage](../templates/storage)
- [documents](../templates/documents)
- [networking](../templates/networking)
    - [docker_cloudflare-tunnel](../templates/networking/docker_cloudflare-tunnel) 
- [bookmarking](../templates/bookmarking)

## All Templates

- [dashboards](../templates/dashboards)
  - [docker_squirrel_server_manager](../templates/dashboards/docker_squirrel_server_manager)
  - [docker_dashy](../templates/dashboards/docker_dashy)
- [llm](../templates/llm)
  - [docker_ollama_webui](../templates/llm/docker_ollama_webui)
- [backup](../templates/backup)
  - [kopia](../templates/backup/kopia)
  - [docker_git-sync](../templates/backup/docker_git-sync)
  - [docker_backrest](../templates/backup/docker_backrest)
  - [docker_gickup](../templates/backup/docker_gickup)
- [games](../templates/games)
  - [docker_necesse](../templates/games/docker_necesse)
  - [docker_minecraft_server](../templates/games/docker_minecraft_server)
  - [docker_vrising-server](../templates/games/docker_vrising-server)
  - [docker_valheim_server](../templates/games/docker_valheim_server)
  - [docker_crafty_minecraft](../templates/games/docker_crafty_minecraft)
  - [docker_satisfactory](../templates/games/docker_satisfactory)
  - [docker_palworld_server](../templates/games/docker_palworld_server)
  - [docker_enshrouded_server](../templates/games/docker_enshrouded_server)
  - [docker_terraria-server](../templates/games/docker_terraria-server)
- [monitoring_alerting](../templates/monitoring_alerting)
  - [docker_watchtower](../templates/monitoring_alerting/docker_watchtower)
  - [docker_graylog](../templates/monitoring_alerting/docker_graylog)
  - [docker_uptime-kuma](../templates/monitoring_alerting/docker_uptime-kuma)
  - [docker_beszel](../templates/monitoring_alerting/docker_beszel)
  - [docker_monitoring](../templates/monitoring_alerting/docker_monitoring)
  - [docker_netdata](../templates/monitoring_alerting/docker_netdata)
    - [server](../templates/monitoring_alerting/docker_netdata/server)
    - [agent](../templates/monitoring_alerting/docker_netdata/agent)
- [automation](../templates/automation)
  - [docker_semaphore](../templates/automation/docker_semaphore)
  - [docker_prefect_server](../templates/automation/docker_prefect_server)
  - [docker_rundeck](../templates/automation/docker_rundeck)
  - [docker_windmill](../templates/automation/docker_windmill)
  - [docker_huginn](../templates/automation/docker_huginn)
  - [docker_gh-runner](../templates/automation/docker_gh-runner)
  - [docker_olivetin](../templates/automation/docker_olivetin)
  - [docker_beehive](../templates/automation/docker_beehive)
  - [docker_concourse_ci](../templates/automation/docker_concourse_ci)
  - [docker_n8n](../templates/automation/docker_n8n)
- [rss](../templates/rss)
  - [docker_tinytinyrss](../templates/rss/docker_tinytinyrss)
  - [docker_rsshub](../templates/rss/docker_rsshub)
  - [docker_yarr](../templates/rss/docker_yarr)
  - [docker_commafeed](../templates/rss/docker_commafeed)
  - [docker_feedless](../templates/rss/docker_feedless)
  - [docker_freshrss](../templates/rss/docker_freshrss)
- [bots](../templates/bots)
  - [docker_red-discordbot](../templates/bots/docker_red-discordbot)
- [web_scraping](../templates/web_scraping)
  - [docker_selenium_hub](../templates/web_scraping/docker_selenium_hub)
- [security](../templates/security)
  - [docker_remnux](../templates/security/docker_remnux)
  - [docker_netalertx](../templates/security/docker_netalertx)
  - [docker_vaultwarden](../templates/security/docker_vaultwarden)
  - [docker_wazuh](../templates/security/docker_wazuh)
- [messaging](../templates/messaging)
  - [docker_mosquitto](../templates/messaging/docker_mosquitto)
  - [docker_rabbitmq](../templates/messaging/docker_rabbitmq)
- [database](../templates/database)
  - [docker_nocodb](../templates/database/docker_nocodb)
  - [docker_baserow](../templates/database/docker_baserow)
  - [docker_influxdb](../templates/database/docker_influxdb)
  - [docker_prometheus](../templates/database/docker_prometheus)
  - [docker_mongodb](../templates/database/docker_mongodb)
  - [docker_postgresql](../templates/database/docker_postgresql)
  - [docker_mysql](../templates/database/docker_mysql)
  - [docker_cloudbeaver](../templates/database/docker_cloudbeaver)
  - [docker_redis](../templates/database/docker_redis)
  - [web_uis](../templates/database/web_uis)
    - [docker_redis-commander](../templates/database/web_uis/docker_redis-commander)
    - [docker_cloudbeaver](../templates/database/web_uis/docker_cloudbeaver)
    - [docker_mysql_workbench](../templates/database/web_uis/docker_mysql_workbench)
- [code_forges](../templates/code_forges)
  - [docker_coder](../templates/code_forges/docker_coder)
  - [docker_forgejo](../templates/code_forges/docker_forgejo)
  - [docker_gitea](../templates/code_forges/docker_gitea)
  - [docker_drone](../templates/code_forges/docker_drone)
- [notifications](../templates/notifications)
  - [docker_ntfy](../templates/notifications/docker_ntfy)
- [misc](../templates/misc)
  - [docker_omnitools](../templates/misc/docker_omnitools)
  - [project_templates](../templates/misc/project_templates)
    - [docker_node-server](../templates/misc/project_templates/docker_node-server)
    - [docker_wordpress-template](../templates/misc/project_templates/docker_wordpress-template)
    - [docker_wordpress-nginx](../templates/misc/project_templates/docker_wordpress-nginx)
      - [example_wordpress](../templates/misc/project_templates/docker_wordpress-nginx/example_wordpress)
      - [nginx-proxy](../templates/misc/project_templates/docker_wordpress-nginx/nginx-proxy)
- [file_transfer](../templates/file_transfer)
  - [docker_sftpgo](../templates/file_transfer/docker_sftpgo)
- [media](../templates/media)
  - [docker_plex](../templates/media/docker_plex)
  - [docker_download-suite](../templates/media/docker_download-suite)
  - [docker_photoprism](../templates/media/docker_photoprism)
  - [docker_calibre](../templates/media/docker_calibre)
  - [docker_prowlarr](../templates/media/docker_prowlarr)
  - [docker_emby](../templates/media/docker_emby)
- [storage](../templates/storage)
  - [docker_baserow](../templates/storage/docker_baserow)
  - [docker_seafile-server](../templates/storage/docker_seafile-server)
  - [docker_minio](../templates/storage/docker_minio)
  - [docker_opengist](../templates/storage/docker_opengist)
  - [docker_bytestash](../templates/storage/docker_bytestash)
- [documents](../templates/documents)
  - [docker_kiwix_server](../templates/documents/docker_kiwix_server)
  - [docker_obsidian_web](../templates/documents/docker_obsidian_web)
  - [docker_paperless-ng](../templates/documents/docker_paperless-ng)
  - [docker_paperless-ngx](../templates/documents/docker_paperless-ngx)
  - [docker_mayan-edms](../templates/documents/docker_mayan-edms)
  - [docker_docspell](../templates/documents/docker_docspell)
- [networking](../templates/networking)
  - [docker_portall](../templates/networking/docker_portall)
  - [docker_wg-easy](../templates/networking/docker_wg-easy)
  - [docker_newt-tunnel](../templates/networking/docker_newt-tunnel)
  - [docker_nginx-proxy-manager](../templates/networking/docker_nginx-proxy-manager)
  - [docker_headscale](../templates/networking/docker_headscale)
  - [docker_technitiumdns](../templates/networking/docker_technitiumdns)
  - [docker_portainer](../templates/networking/docker_portainer)
  - [docker_rustdesk_server](../templates/networking/docker_rustdesk_server)
  - [docker_pangolin](../templates/networking/docker_pangolin)
  - [docker_unifi-controller](../templates/networking/docker_unifi-controller)
  - [docker_traefik](../templates/networking/docker_traefik)
  - [docker_dockge](../templates/networking/docker_dockge)
  - [docker_meshping](../templates/networking/docker_meshping)
  - [docker_adguard](../templates/networking/docker_adguard)
  - [docker_cloudflare-tunnel](../templates/networking/docker_cloudflare-tunnel)
- [bookmarking](../templates/bookmarking)
  - [docker_linkding](../templates/bookmarking/docker_linkding)
  - [docker_shaarli](../templates/bookmarking/docker_shaarli)
  - [docker_shiori](../templates/bookmarking/docker_shiori)
  - [docker_grimoire](../templates/bookmarking/docker_grimoire)
  - [docker_karakeep](../templates/bookmarking/docker_karakeep)
  - [docker_linkwarden](../templates/bookmarking/docker_linkwarden)
  - [docker_wallabag](../templates/bookmarking/docker_wallabag)
  - [docker_readeck](../templates/bookmarking/docker_readeck)