# Garage S3

[Garage](https://garagehq.deuxfleurs.fr) is a selfhostable, S3-compatible object storage container. It is a popular alternative to Minio, which is dead to me now.

## Setup

- Copy the [example `.env` file](.env.example) to `.env`
- Generate secrets with [`./generate_secrets.sh`](./generate_secrets.sh)
  - Paste the values into their appropriate vars in `.env`
- Copy [the example `garage.toml`](./config/garage/example.garage.toml) to `./config/garage/garage.toml`
  - Edit the file, change `rpc_public_addr` to your ip address or hostname
     - i.e. `"192.168.1.100:3901` or `"domain.lan:3901"` or `"garage.yourdomain.com:3901`
- Bring the stack up with:

  ```shell
  docker compose -f compose.yml -f overlays/garage-ui.yml up -d
  ```
- Navigate to the webui at `http://ip-or-fqdn:3909`

Before you can actually use Garage, you need to initialize the layout. In the webUI, navigate to `cluster` and make note of the `Capacity` column. You need to initialize the node for storage by clicking the 3-dot menu on your node, then clicking "Assign." In the pop-up window, set `Capacity` to a number less than or equal to the value in the `Capactity` column on the previous screen. Optionally, add it to a zone and/or give the node tag(s).

## Use a local data dir

Create a directory, i.e. `./data`, and set the owner to `999:999`:

```shell
mkdir -p ./data
sudo chown -R 999:999 ./data
sudo chmod -R 755 ./data
```

Then, set `GARAGE_DATA_DIR=./data`.

