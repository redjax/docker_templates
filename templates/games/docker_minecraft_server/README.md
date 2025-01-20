# Docker Minecraft Server <!-- omit in toc -->

<!-- Repo image -->
<p align="center">
  <a href="https://github.com/redjax/docker_templates">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="./minecraft-logo-1015.png">
      <img src="./minecraft-logo-1015.png" height="100">
    </picture>
  </a>
</p>

Dockerized Minecraft server.

The [itz/minecraft-server container](https://hub.docker.com/r/itzg/minecraft-server) is a highly configurable server environment that supports vanilla server creation or modded with Fabric, Spiget, etc.

```
WARNING: This path is undergoing active development.

Consider this template unstable until this message is reviewed.
```

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Usage](#usage)
  - [Env setup](#env-setup)
  - [Player whitelist.json](#player-whitelistjson)
  - [Modded server](#modded-server)
- [Links](#links)

## Usage

There are multiple ways to run this Dockerized Minecraft server container. You can copy the example files like [`.env.example`](./.env.example) and [`./whitelist.example.json`](./whitelist.example.json) and run the [`compose.yml` file](./compose.yml) directly from this git repository. Using this method, you will run 1 server at a time.

You can also copy the entire [`../docker_minecraft_server`](../docker_minecraft_server/) to another path on your filesystem, outside of the `docker_templates/` repository clone. You can edit the environment and whitelist files at that path, and create multiple isolated Minecraft servers this way. Any changes made in this repository template will need to be manually applied to your detached Minecraft servers.

### Env setup

Copy [`.env.example`](./.env.example) to `.env`. Edit it to your liking, or leave the defaults.

**TODO**: Write documentation for using [`env_file`s](./envs).

### Player whitelist.json

You can add players to a [`whitelist.json`] file before starting your server if you know their username and UUID. You can use [mcuuid.net](https://mcuuid.net) to look up a player's UUID by username or username by UUID.

When using a whitelist, you need to set `MC_SERV_WHITELIST_ENABLED=true` in the [`.env` file](./.env.example).

Create a `whitelist.json` by copying [`whitelist.example.json`](./whitelist.example.json) to `whitelist.json`.

A valid `whitelist.json` looks like this (replace the default values with your own, copy/paste `{key/value pairs}` for as many players you will allow to connect):

```json
[
    {
        "uuid": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
        "name": "username"
    },
    {
        "uuid": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
        "name": "username"
    }
]
```

When using a whitelist, you need to edit the [`compose.yml` file](./compose.yml); uncomment the `# - ${MC_SERVER_WHITELIST_FILE:-./whitelist.json}:/extra/whitelist.json` line.

### Modded server

*[`minecraft-server` Docs: Working with mods and plugins](https://docker-minecraft-server.readthedocs.io/en/latest/mods-and-plugins/)* | 
*[`minecraft-server` Docs: Server types and modpack platforms](https://docker-minecraft-server.readthedocs.io/en/latest/types-and-platforms/)*

Set the [`TYPE=<mod-manager>` environment variable](https://docker-minecraft-server.readthedocs.io/en/latest/types-and-platforms/) in your [`.env` file](./.env.example) to one of the following:

| .env `TYPE=` | Description |
| ------ | ----------- |
| [`VANILLA`](https://docker-minecraft-server.readthedocs.io/en/latest/types-and-platforms/) | The default, vanilla Minecraft server provided by Mojang. |
| [`AUTO_CURSEFORGE`](https://docker-minecraft-server.readthedocs.io/en/latest/types-and-platforms/mod-platforms/auto-curseforge/) | Automated Curse Forge modpacks, keeping everything automatically updated. |
| [`CURSEFORGE`](https://docker-minecraft-server.readthedocs.io/en/latest/types-and-platforms/mod-platforms/curseforge/) | A manual Curse Forge server. "Manual" means you are responsible for downloading & updating the mods. |
| [`FTBA`](https://docker-minecraft-server.readthedocs.io/en/latest/types-and-platforms/mod-platforms/ftb/) |  FeedTheBeast modpacks support. |
| [`MODRINTH`](https://docker-minecraft-server.readthedocs.io/en/latest/types-and-platforms/mod-platforms/modrinth-modpacks/)  | Manage mods with [Modrinth](https://modrinth.com) |
| [`FABRIC`](https://docker-minecraft-server.readthedocs.io/en/latest/types-and-platforms/server-types/fabric/) | Manage mods with a [Fabric server](https://fabricmc.net/) |
| [`FORGE`](https://docker-minecraft-server.readthedocs.io/en/latest/types-and-platforms/server-types/forge/) | Manage mods with a [Forge server](http://www.minecraftforge.net/) |
| [`QUILT`](https://docker-minecraft-server.readthedocs.io/en/latest/types-and-platforms/server-types/quilt/) | Manage mods with a [Quilt server](https://quiltmc.org/) |

Note that some of the `TYPE` values can take other values, like if `TYPE="QUILT"`, you can set `QUILT_LOADER_VERSION=...` and `QUILT_INSTALLER_VERSION=...`.

## Links

- [Docker Hub: itzg/minecraft-server](https://hub.docker.com/r/itzg/minecraft-server)
- [Github: itzg/minecraft-server](https://github.com/itzg/docker-mc-backup)
- [itzg/minecraft-server Docs](https://docker-minecraft-server.readthedocs.io/en/latest/)
- [Blog: Minecraft Server in Docker: Adulting Made Easy](https://serialized.net/2021/02/minecraft_server_docker/)
- [Github: jbarratt/docker-homelab](https://github.com/jbarratt/docker-homelab/blob/main/minecraft.yml)
- [Github: itzg/docker-mc-backup](https://github.com/itzg/docker-mc-backup)
