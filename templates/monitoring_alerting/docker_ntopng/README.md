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

