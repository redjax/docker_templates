# Mods.txt files

When using a modded Minecraft server, you can mount a `mods.txt` file to the container's `/extras/mods.txt` path. Edit the `compose.yml` file's `volumes:` section, adding (or uncommenting) this line:

```yaml
---
services:
  mc-server:
    ...
    volumes:
      - mods_files/your-mods-file.txt:/extras/mods.txt
```

A `mods.txt` file should have links to mod downloads, each on their own line. `# comments` are ignored:

```text
## https://docker-minecraft-server.readthedocs.io/en/latest/mods-and-plugins/#modplugin-url-listing-file

https://edge.forgecdn.net/files/2965/233/Bookshelf-1.15.2-5.6.40.jar
https://edge.forgecdn.net/files/2926/27/ProgressiveBosses-2.1.5-mc1.15.2.jar
# This and next line are ignored
#https://edge.forgecdn.net/files/3248/905/goblintraders-1.3.1-1.15.2.jar
https://edge.forgecdn.net/files/3272/32/jei-1.15.2-6.0.3.16.jar
https://edge.forgecdn.net/files/2871/647/ToastControl-1.15.2-3.0.1.jar

```
