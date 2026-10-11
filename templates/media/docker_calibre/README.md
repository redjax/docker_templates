# Calibre/Calibre-Web

## Setup

- Copy the [example `.env` file](./.env.example) to `.env`
- Check the [`overlays/` directory](./overlays/) to determine which additional service layer(s) you want to use
  - For service you're going to run alongside Calibre, make sure to review the service's variables in `.env` and change any to your liking

## Usage

Run the stack with:

```shell
docker compose up -d
```

If you are using any of the [overlays](./overlays/), add them with `-f overlays/<overlay-name>.yml`:

```shell
docker compose -f compose.yml \
  -f overlays/calibre-web.yml \  # Run Calibre web with Calibre
  -f overlays/sftpgo.yml \       # Run SFTPGo with Calibre
  up -d
```

### Plugins

You can install most plugins through the built-in plugin manager. Some plugins need to be downloaded as a `.zip` file and copied into `./calibre/plugins`. You can also do this with the [SFTPGo layer](./overlays/sftpgo.yml).

Useful plugins list:

- DeDRM Tools *[Github](https://github.com/noDRM/DeDRM_tools)*
  - This plugin must be installed by copying into `docker_calibre/calibre/plugins`. It is not available in the plugin manager
  - Download the `.zip` file and extract. The `.zip` files within the extracted archive are the plugins
- Find Duplicates
- Mass Search & Replace
- KFX Input *[MobileRead.com](https://www.mobileread.com/forums/showthread.php?t=291290)*
  - Convert Kindle KFX books to other formats
- Kindle Collections
  - Manage Kindle collections in Calibre
- EpubMerge
- EpubSplit
- Job Spy
  - Make Calibre more useful
- Annotations
  - Fetch annotations (highlights, notes, etc) from eBook readers (like Kindle)
- Count Pages
  - Get a page count for selected book
- Favorites Menu *[MobileRead.com](https://www.mobileread.com/forums/showthread.php?t=183022)*
  - Customize a menu of favorite buttons

## Notes

- Calibre-web default login:
  - User: `admin`
  - Password: `admin123`
