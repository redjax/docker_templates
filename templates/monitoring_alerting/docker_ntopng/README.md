# NTopNG

[ntopng](https://github.com/ntop/ntopng) is a web-based traffic & security network traffic monitoring tool.

## Usage

### Quick Run

You can quickly start an `ntopng` container with:

```shell
docker run -it -d \
    --name "$CONTAINER_NAME" \
    --net=host \
    --restart=unless-stopped \
    -v "$CONFIG_DIR":/etc/ntopng \
    -v "$DATA_DIR":/var/tmp/ntopng \
    -e "NTOPNG_ADMIN_PASSWORD=$ADMIN_PASSWORD" \
    ntop/ntopng:latest \
    "${IFS_ARGS[@]}" \
    -w "$WEB_PORT"
```

## Tips

### List interfaces monitoring by container

```shell
docker exec -it ntopng ps aux | grep ntopng
```

## Troubleshooting

### Fix: Packets exceedomg expected max size

If you see messages like this:

```log
ntopng  | DD/MON/YYYY 00:00:00 [NetworkInterface.cpp:2742] Packets exceeding the expected max size have been received [eth0][len: 1523][max len: 1518].
ntopng  | DD/MON/YYYY 00:00:00 [NetworkInterface.cpp:2748] WARNING: If TSO/GRO is enabled, please disable it for best accuracy
ntopng  | DD/MON/YYYY 00:00:00 [NetworkInterface.cpp:2752] WARNING: using: sudo ethtool -K eth0 gro off gso off tso off
```

It means that `ntopng` tried to inspect a packet that was too large. `ntopng` expects Ethernet frames to be a maximum of 1518 bytes (standard Ethernet MTU). If a packet is larger than thatt, it is dropped. This can interfere with things like active monitoring, but does not stop `ntopng` from working.

To fix it, run the command it suggests. Replace `<interface>` with your interface name from the message (i.e. `eth0` in the error above):

```shell
sudo ethtool -K <interface> gro off gso off tso off
```

You may need to install the `ethtool` package.
