# Ark: Survival Evolved

Dockerized Ark: Survival Evolved server.

Image: [TuRzam/Ark-docker](https://github.com/TuRz4m/Ark-docker/tree/master)

## Resource limits

Ark details the system requirements for running in Ark serveron [their wiki](https://ark.wiki.gg/wiki/Dedicated_server_setup#Prerequisites). The container deploys with limits on these resources, configurable with the `ARK_SERVER_CPU_LIMIT` and `ARK_SERVER_CPU_RESEREVED` environment variables.

The [wiki.gg page for Ark](https://ark.wiki.gg/wiki/Dedicated_server_setup) lists server requirements for Survival Evolved and Survival Ascended servers.

For RAM, note this from the wiki:

> with each player connected the memory requirements may rise by an average of 50-150MiB

Keep this in mind when setting the `ARK_SERVER_MEMORY_LIMIT` and `ARK_SERVER_MEMORY_RESERVED` environment variables.
