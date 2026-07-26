# Netbird Client

A [Netbird client](https://docs.netbird.io/get-started/install/docker) allows a peer to join a pre-existing Netbird deployment using a setup key. You can run the container with this Compose stack, or directly using this command (replace the `NB_SETUP_KEY` and `NB_MANAGEMENT_URL` with your own values):

```shell
docker run --rm -d \
 --cap-add=NET_ADMIN \
 -e NB_SETUP_KEY=<your setup key> \
 -v netbird-client:/var/lib/netbird \
 -e NB_MANAGEMENT_URL=https://vpn.example.com \
 netbirdio/netbird:latest
```

