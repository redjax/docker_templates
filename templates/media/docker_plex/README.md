# Docker_Plex

Instructions: Clone repository, copy .env.example to a new .env file. (Optional) change .env variables for storage (i.e. add a path to media folders for Plex), then run docker-compose up -d.

By default, this will create 3 containers:

* Plex server
* [Kitana](https://github.com/pannal/Kitana) (for loading plugins)
* [Tautulli](https://tautulli.com) (for Plex server stats)

Kitana and Tautulli are optional and can be disabled by commenting the service sections in docker-compose.yml.

## First run

The compose file will create folders for each service's configuration. You can access Plex and Tautulli like:

* Plex: `http://<server-ip>:32400`
* Tautulli: `http://<server-ip>:8181`
    * This can be overridden by changing the value of `TAUTULLI_WEB_PORT=` in [.env](.env.example)

## Manually install Plex plugins

* Download plugin zip
* Copy into `/config/Library/Application Support/Plex Media Server/Plex Media Server`
    * If you specified another location for the Plex config directory in .env file (`PLEX_CONF_DIR=`), use that directory instead of "Plex" specified above
* Unzip plugin and delete .zip file
* Restart compose stack (docker-compose up -d)

## Troubleshooting

### Reclaim server after password reset

If you reset your password and choose the "sign out of all devices" option, your server will become unclaimed. To fix this, follow the steps below.

- Stop the Plex container.
- Open the Plex server's preferences at `/config/Library/Application Support/Plex Media Server/Preferences.xml` in the container.
  - If you mounted it to a local directory on the host, look for the `config/` directory.
- Edit the `Preferences.xml` file.
  - Copy the `MachineIdentifier` UUID (you will need this in a moment).
  - Clear out the value of `PlexOnlineToken`.
    - `PlexOnlineToken="xxxxxxxxxxxxxxxxxxxx"` -> `PlexOnlineToken=""`
- Navigate to [https://www.plex.tv/claim](https://www.plex.tv/claim), sign in, and copy the claim token.
- Make a cURL request, replacing `{processed_machine_identifier}` with the `MachineIdentifier` code you copied, and `{claim_token}` with the `PlexOnlineToken` value.
  - Linux/Mac: `curl -X POST -s -H "X-Plex-Client-Identifier: {processed_machine_identifier}" "https://plex.tv/api/claim/exchange?token={claim_token}"`
  - Windows: `Invoke-WebRequest -Uri "https://plex.tv/api/claim/exchange?token={claim_token}" -Method Post -Headers @{ "X-Plex-Client-Identifier" = {processed_machine_identifier} -UseBasicParsing`
- In the response you get, look towards the bottom for `authentication-token`.
  - Copy the value and paste it into the `Preferences.xml` file at `PlexOnlineToken` (the value you cleared out earlier).
  - Make sure `AcceptEULA` is `1`.
- Restart the Plex container and navigate to the webUI, and your server should be claimed.

**Sources**

- [plexopedia.com: Claiming your server manually](https://www.plexopedia.com/plex-media-server/general/claim-server/#:~:text=Open%20a%20Web%20browser%20and,Copy%20this%20token.&text=Replace%20%7Bprocessed_machine_identifier%7D%20with%20the%20value,token%20from%20the%20Web%20page)
- [Reddit thread about the unclaimed server issue](https://www.reddit.com/r/PleX/comments/1nc6ox6/for_those_having_extreme_difficulty_reclaiming/)
