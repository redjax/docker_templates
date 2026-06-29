# SFTPGo

Full-featured and highly configurable SFTP, HTTP/S, FTP/S and WebDAV server - S3, Google Cloud Storage, Azure Blob

## Usage

### Docker Compose

Copy the [example `.env` file](./.env.example) to `.env` and edit it to your needs. You can also run the stack as-is to use named volumes and the default ports (`:8080` for the webUI and `:2022` for the SSH port).

Run the stack from this directory with `docker compose up -d`.

### Quick Docker

To quickly spin up an SFTPGo server using a path on your host as the data directory in the container, run the command below, replacing `$HOST_PATH` with a path on your machine that you want to share or store SFTPGo data in:

```bash
docker run --name sftpgo \
    -p 8080:8080 \
    -p 2022:2022 \
    -e SFTPGO_GRACE_TIME=32 \
    -v $HOST_PATH:/srv/sftpgo \
    -d \
    "drakkan/sftpgo:latest"

```

## Links

- [SFTPGo Home](https://sftpgo.com)
- [SFTPGo Github](https://github.com/drakkan/sftpgo)
  - [SFTPGo Github: Example configuration file](https://github.com/drakkan/sftpgo/blob/2.6.x/sftpgo.json)
- [SFTPGo Docs](https://docs.sftpgo.com/latest/)
  - [SFTPGo Docs: Configure with environment variables](https://docs.sftpgo.com/latest/env-vars/)
  - [SFTPGo Docs: configuration file](https://docs.sftpgo.com/latest/config-file/)
