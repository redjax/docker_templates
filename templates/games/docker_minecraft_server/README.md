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
  - [Modded server](#modded-server)
- [Links](#links)

## Usage

- Copy [`.env.example`](./.env.example) to `.env`.
  - Edit it to your liking, or leave the defaults.
- (Optional) Create a `whitelist.json`
  - If you know your players' usernames and UUIDs, you can copy the [`whitelist.example.json`](./whitelist.example.json) to `whitelist.json` and edit it to add them.
  - If you use a whitelist:
    - Set the `MC_SERV_WHITELIST_ENABLED=true` variable in your [`.env` file](./.env.example)
    - Uncomment the `# - ${MC_SERV_WHITELIST_FILE:-./whitelist.json}:/extra/whitelist.json` line in the [`compose.yml` file](./compose.yml).

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
