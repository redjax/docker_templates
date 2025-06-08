# Pangolin Newt

[Newt](https://github.com/fosrl/newt) is the Pangolin tunnel service that connects your backend servers to your Pangolin instance.

## Setup

Copy and paste the [`compose.yml`](./compose.yml) to your backend server. Create a `.env` file and copy the contents of the [example `.env` file](./.env.example). Set your proxy's URL, and your newt ID/secret, then run `docker compose up -d`.

After running the Newt container, you can use your server's local IP (your LAN IP for the machine) in Pangolin's webUI to create a "resource." For example, if you have a service running on your local machine on port `:8084`, you can create a service and use `192.168.1.xxx:8084` and Pangolin's server will be able to find it, even if the Pangolin server and local backend are in different countries!

## Troubleshooting

### Failed ICMP pings to Pangolin server

You may have trouble connecting your Pangolin (VPS/remote server) and Newt (local agent) machines, where the Newt container will fail to ping the Pangolin server, producing warnings and errors like this:

```shell
pangolin-newt  | INFO: YYYY/mm/dd HH:MM:SS Ping attempt 2
pangolin-newt  | INFO: YYYY/mm/dd HH:MM:SS Pinging 100.89.128.1
pangolin-newt  | WARN: YYYY/mm/dd HH:MM:SS Ping attempt 1 failed: failed to read ICMP packet: i/o timeout
```

When this happens, make sure you've opened your Wireguard port on the Pangolin server (default is `51820/udp`). You may also need to open this port on the local machine. You will need to allow traffic IN and OUT.

For example, with `ufw`:

```shell
sudo ufw allow in 51820/udp && sudo ufw allow out 51820/udp && sudo ufw reload
```

Start by opening this port only on the Pangolin server to see if it can connect; if you still have trouble connecting with the Newt container, run the commands above on the Newt container's host, too.
