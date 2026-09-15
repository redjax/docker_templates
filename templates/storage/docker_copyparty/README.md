# Copyparty

[Copyparty](https://copyparty.eu/) is a portable file server loaded with features and support for many protocols.

## Setup

- Copy [example `.env` file](./.env.example) to `.env`
  - Optionally change any defaults, i.e. the `COPYPARTY_HTTP_PORT`
- Copy [an example config file](./examples/config/) into the [`config/` directory](./config/) and name it `copyparty.conf`.
  - You can use the [`00-example-full.conf` file](./examples/config/00-example-full.conf) as a reference for [Copyparty's options](https://github.com/9001/copyparty/tree/hovudstraum#server-config)
  - See the ["`copyparty.conf` File" section](#copypartyconf-file) for more info
  - You can configure user/password based access per-route in the `copyparty.conf` file. Make note of any passwords you set this way so you can log into the UI.

### copyparty.conf File

Copyparty looks for a file named `copyparty.conf` to determine what settings to use. The values in this file are equivalent to running the `copyparty` command with `--args`.

Check the [Github README for more information about configuring the server](https://github.com/9001/copyparty#server-config).

There are example files in [`examples/config`](./examples/config/) that you can copy/paste into a [`config/copypart.conf`](./config/) for the Copyparty server running in Docker. See Copyparty's [example `copyparty.conf` for all options](https://github.com/9001/copyparty/blob/hovudstraum/docs/example.conf).

### Fileshare

The container uses `/w` in the container as the fileshare root. The `COPYPARTY_FILESHARE_ROOT_DIR` environment variable controls where that container path is mounted. The default is a named Docker volume called `fileshare`, but you can set a host path, i.e. `./fileshare`, to bind to a host volume instead.

If you want to share an existing path on the host, i.e. `/opt/some-app/data`, you would set `COPYPARTY_FILESHARE_ROOT_DIR="/opt/some-app/data"`.

### PUID and PGID

The `PUID` and `PGID` environment variables control the user access level the container runs with. By default this is `PUID=1000` and `PGID=1000`. If you are [mounting a host volume for your fileshare](#fileshare), make sure to set `PUID` and `PGID` to a user with access to that path.

If you want to explore the host volume path Copyparty uses, get your Linux user ID with the `id` command:

```shell
exampleuser@hostname>id
uid=1234(exampleuser) gid=1234(exampleuser) groups=123(docker),27(sudo)
```

In the example above, if you wanted to access the host volume as the `exampleuser` Linux user, you would use `PUID=1234` and `PGID=1234`, assuming that user owns the path you set for `COPYPARTY_FILESHARE_ROOT_DIR`.

## Usage

After doing the [initial setup](#setup), run `docker compose up -d` and navigate to `http(s)://<hostname-or-fqdn>:3923` to access Copyparty's webUI. If you used a different value for `COPYPARTY_HTTP_PORT`, use that value instead of `:3923`.

If you setup access controls in your `copyparty.conf`, 
