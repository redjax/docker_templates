# Chaptarr <!-- omit in toc -->

[Chaptarr](https://github.com/Chaptarr/chaptarr) is a fork of Readarr that fixes a number of issues and adds new features.

## Setup

- Copy the [example `.env` file](./.env) to `.env`
  - Edit the variables, i.e. set the path to an existing Calibre library in `CHAPTARR_EBOOKS_DIR`, or run Chaptarr on a d ifferent port by editing `CHAPTARR_HTTP_PORT`.
- Bring the stack up with `docker compose up -d`
  - To run [one of the overlays](./overlays/), use `-f <compose-file>.yml`.
  - For example, to run the [`flaresolverr.yml` overlay](./overlays/flaresolverr.yml), you would run `docker compose -f compose.yml -f overlays/flaresolverr.yml up -d`.
- Navigate to the webUI (default: `http(s)://<your-fqdn-or-ip>[:port-if-ip]`, i.e. `http://192.168.1.100:8789`).
  - Create a user account.
  - Go to Settings > Download Clients and configure a downloader.
  - For "Audiobook Tags" and "Ebook Tags", use `audiobooks` and `ebooks`.
- Add torrent indexers in Settings > Indexers.
  - You can use a tool like [Jackett](https://github.com/Jackett/Jackett) to find indexers to follow.
- If you have an existing Calibre library, set the path to your Calibre directory in the `.env` file's `CHAPTARR_EBOOKS_DIR`.
  - In the webUI, go to Settings > Media Management > Root Folders and add the container's `/ebooks` path.
  - Chaptarr will automatically import your collection.
