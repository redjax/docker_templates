# Minecraft - BigChadGuys

Modded Minecraft server, running the [BigChadGuys modpack](https://modrinth.com/modpack/bcg)

## Setup

For some reason, this container doesn't automatically download the required [`iris` dependency](https://modrinth.com/mod/iris). You need to manually download an [appropriate version for your server from this page](https://modrinth.com/mod/iris/versions). Place the download in the [`extra_mods/`](./extra_mods/) path, then run the server.

You will also need to download the following on both the server and your client:

- [FTB XMod Compat](https://www.curseforge.com/minecraft/mc-mods/ftb-xmod-compat/download/5257896)
- [FTB Ultimate (Fabric)](https://www.curseforge.com/minecraft/mc-mods/ftb-ultimine-fabric/download/5363344)
- [FTB Teams (Fabric)](https://www.curseforge.com/minecraft/mc-mods/ftb-teams-fabric/download/5267188)
- [FTB Quests (Fabric)](https://www.curseforge.com/minecraft/mc-mods/ftb-quests-fabric/download/5543954)
- [FTB Library (Fabric)](https://www.curseforge.com/minecraft/mc-mods/ftb-library-fabric/download/5567590)
- [FTB Essentials (Forge & Fabric)](https://www.curseforge.com/minecraft/mc-mods/ftb-essentials/download/4896151)
- [FTB Chunks(Fabric)](https://www.curseforge.com/minecraft/mc-mods/ftb-chunks-fabric/download/5378089)
- [BCG Util](https://www.curseforge.com/minecraft/mc-mods/bcg-util/download/5359973)
- [Cobblemon Quests](https://www.curseforge.com/minecraft/mc-mods/cobblemon-quests/download/5640002)

## Cobblemon Commands

- [Cobbelmon Wiki: commands](https://wiki.cobblemon.com/index.php/Commands)

| Command                                                    | Description                                            | Example                                                                                 |
| ---------------------------------------------------------- | ------------------------------------------------------ | --------------------------------------------------------------------------------------- |
| `/givepokemon <pokemon> [attributes]`                      | Give yourself a pokemon                                | `/givepokemon abra shiny ability=synchronize`                                           |
| `/givepokemonother <target> <pokemon> [attributes]`        | Give other player(s) a pokemon                         | `/givepokemonother @a abra shiny ability=synchronize`                                   |
| `/levelup <target> <slot>`                                 | Add +1 to level to pokemon in player's party slot      | `/levelup @p 1`                                                                         |
| `/pokemonedit <slot> [pokemon / attributes]`               | Edit a pokemon in a specified slot                     | `/pokemonedit 1 abra ability=adaptability nature=adamant`                               |
| `/pokemoneditother <target> <slot> [pokemon / attributes]` | Edit a Pokemon in a specified slot of a player's party | `/pokemoneditother PlayerName 1 abra ability=adaptability gender=female nature=adamant` |
