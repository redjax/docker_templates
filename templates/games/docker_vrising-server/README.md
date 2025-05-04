# V Rising

Dockerized [V Rising](https://store.steampowered.com/app/1604030/V_Rising/) server. Based on [TrueOsiris's container](https://github.com/TrueOsiris/docker-vrising).

## Setup

- Copy [`.env.example`] -> `.env`
  - (Optional) Edit default environment variables
- Run `docker compose up -d`
- (Optional) Edit the server/game settings JSON files
  - Once the server finishes downloading & installing, you can find the `ServerGameSettings.json` and `ServerHostSettings.json` files in the path defined in `$VRISING_SERVER_GAME_DATA_DIR`.
  - To change the server defaults, it's easiest to set `$VRISING_SERVER_GAME_DATA_DIR` to a host mount (a directory on the local machine, i.e. `./vrising/game_data`) and edit the files directly (**note**: You may need root/`sudo` to edit the files).
  - Either way, the full path to the JSON configuration files is:
    - `$VRISING_SERVER_GAME_DATA_DIR/VRisingServer_Data/StreamingAssets/Settings/`
    - Edit `ServerGameSettings.json` using the [example game settings file](./configs/example/example.ServerGameSettings.json), and the `ServerHostSettings.json` using the [example server settings file](./configs/example/example.ServerHostSettings.json)

## Game Settings

To change the game settings for a V Rising server, you can edit the `ServerGameSettings.json` in the server's data directory, `$VRISING_SERVER_GAME_DATA_DIR/VRisingServer_Data/StreamingAssets/Settings/ServerGameSettings.json`. If using a host mount, you might need to uses admin privileges to edit the file.

### Customize starting powers with VBloodUnitSettings

In the server's `ServerGameSettings.json`, you can edit the powers new players start with using the `VBloodUnitSettings` key. [This Reddit thread](https://www.reddit.com/r/vrising/comments/vbd6e2/how_to_use_server_setting_vbloodunitsettings/) describes how to use the setting. [This article](https://techraptor.net/gaming/guides/v-rising-server-setup-and-config-guide) describes some of the settings and their effects.

You can use the table below as a reference.

| Boss                                                                                     | UnitId       | UnitLevel |
| ---------------------------------------------------------------------------------------- | ------------ | --------- |
| [Alpha Wolf](https://vrisingwiki.net/Alpha_Wolf)                                         | -1905691330  | 16        |
| [Keely the Frost Archer](https://vrisingwiki.net/Keely_the_Frost_Archer)                 | 1124739990   | 20        |
| [Rufus the Foreman](https://vrisingwiki.net/Rufus_the_Foreman)                           | 2122229952   | 20        |
| [Errol the Stonebreaker](https://vrisingwiki.net/Errol_the_Stonebreaker)                 | -2025101517  | 20        |
| [Lidia the Chaos Archer](https://vrisingwiki.net/Lidia_the_Chaos_Archer)                 | 763273073    | 26        |
| [Grayson the Armourer](https://vrisingwiki.net/Grayson_the_Armourer)                     | 1106149033   | 27        |
| [Goreswine the Ravager](https://vrisingwiki.net/Goreswine_the_Ravager)                   | 577478542    | 27        |
| [Putrid Rat](https://vrisingwiki.net/Putrid_Rat)                                         | -2039908510  | 30        |
| [Clive the Firestarter](https://vrisingwiki.net/Clive_the_Firestarter)                   | 1896428751   | 30        |
| [Polora the Feywalker](https://vrisingwiki.net/Polora_the_Feywalker)                     | -484556888   | 34        |
| [Ferocious Bear](https://vrisingwiki.net/Ferocious_Bear)                                 | -1391546313  | 36        |
| [Nicholaus the Fallen](https://vrisingwiki.net/Nicholaus_the_Fallen)                     | 153390636    | 37        |
| [Quincey the Bandit King](https://vrisingwiki.net/Quincey_the_Bandit_King)               | -1659822956  | 37        |
| [Beatrice the Tailor](https://vrisingwiki.net/Beatrice_the_Tailor)                       | -1942352521  | 38        |
| [Vincent the Frostbringer](https://vrisingwiki.net/Vincent_the_Frostbringer)             | -29797003    | 40        |
| [Christina the Sun Priestess](https://vrisingwiki.net/Christina_the_Sun_Priestess)       | -99012450    | 44        |
| [Leandra the Shadow Priestess](https://vrisingwiki.net/Leandra_the_Shadow_Priestess)     | 939467639    | 46        |
| [Tristan the Vampire Hunter](https://vrisingwiki.net/Tristan_the_Vampire_Hunter)         | 1449631170   | 46        |
| [Terah the Geomancer](https://vrisingwiki.net/Terah_the_Geomancer)                       | -1065970933  | 48        |
| [Meredith the Bright Archer](https://vrisingwiki.net/Meredith_the_Bright_Archer)         | 850622034    | 52        |
| [Frostmaw the Moutain Terror](https://vrisingwiki.net/Frostmaw_the_Mountain_Terror)      | 24378719     | 56        |
| [Octavian the Militian Caption](https://vrisingwiki.net/Octavian_the_Militia_Captain)    | 1688478381   | 58        |
| [Raziel the Shepherd](https://vrisingwiki.net/Raziel_the_Shepherd)                       | -680831417   | 60        |
| [Ungora the Spider Queen](https://vrisingwiki.net/Ungora_the_Spider_Queen)               | -548489519   | 60        |
| [The Duke Balaton](https://vrisingwiki.net/The_Duke_of_Balaton)                          | -203043163   | 62        |
| [Jade the Vampire Hunter](https://vrisingwiki.net/Jade_the_Vampire_Hunter)               | -1968372384  | 62        |
| [Foulrot the Soultaker](https://vrisingwiki.net/Foulrot_the_Soultaker)                   | -1208888966  | 62        |
| [Willfred the Werewolf Chief](https://vrisingwiki.net/Willfred_the_Werewolf_Chief)       | -1007062401  | 64        |
| [Mairwyn the Elementalist](https://vrisingwiki.net/Mairwyn_the_Elementalist)             | -2013903325, | 64        |
| [Morian the Stormwing Matriarch](https://vrisingwiki.net/Morian_the_Stormwing_Matriarch) | 685266977    | 68        |
| [Azariel the Sunbringer](https://vrisingwiki.net/Azariel_the_Sunbringer)                 | 114912615    | 68        |
| [Terrorclaw the Ogre](https://vrisingwiki.net/Terrorclaw_the_Ogre)                       | -1347412392  | 68        |
| [Matka the Curse Weaver](https://vrisingwiki.net/Matka_the_Curse_Weaver)                 | -910296704   | 72        |
| [Nightmarshal Styx the Sunderer](https://vrisingwiki.net/Nightmarshal_Styx_the_Sunderer) | 1112948824   | 76        |
| [Gorecrusher the Behemoth](https://vrisingwiki.net/Gorecrusher_the_Behemoth)             | -1936575244  | 78        |
| [The Winged Horror](https://vrisingwiki.net/The_Winged_Horror)                           | -393555055   | 78        |
| [Solarus the Immaculate](https://vrisingwiki.net/Solarus_the_Immaculate)                 | -740796338   | 80        |

## Links

- [TrueOsiris/docker-vrising](https://github.com/TrueOsiris/docker-vrising)
- [fandom: V Rising dedicated server wiki](https://vrising.fandom.com/wiki/V_Rising_Dedicated_Server)
- [TechRaptor: V Rising Server Setup and Config Guide](https://techraptor.net/gaming/guides/v-rising-server-setup-and-config-guide)
- [Reddit: how to use server setting VBloodUnitSettings](https://www.reddit.com/r/vrising/comments/vbd6e2/how_to_use_server_setting_vbloodunitsettings/)
