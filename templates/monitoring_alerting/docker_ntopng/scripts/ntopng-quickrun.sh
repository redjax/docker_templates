#!/usr/bin/env bash
set -euo pipefail

##
# Run ntopng + Redis in Docker with configurable options
##

# Default config
INTERFACES=("eth0")
WEB_PORT=3000
REDIS_PORT=6379
ADMIN_PASSWORD="admin"
CONFIG_DIR="./ntopng/config"
DATA_DIR="./ntopng/data"
REDIS_DATA_DIR="./ntopng/redis/data"
CONTAINER_NAME="ntopng"
REDIS_NAME="${CONTAINER_NAME}-redis"

usage() {
    echo "Usage: $0 [-i iface]... [-p web_port] [-P admin_password] [-c config_dir] [-d data_dir] [-r redis_port]"
    echo "  -i, --interface      Network interface to monitor (can be used multiple times, default: eth0)"
    echo "  -p, --port           Web UI port (default: $WEB_PORT)"
    echo "  -r, --redis-port     Redis port (default: $REDIS_PORT)"
    echo "  -P, --password       Admin password (default: $ADMIN_PASSWORD)"
    echo "  -c, --config-dir     Config directory (default: $CONFIG_DIR)"
    echo "  -d, --data-dir       Data directory (default: $DATA_DIR)"
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -i|--interface)
            shift
            [ -z "${1-}" ] && usage
            INTERFACES+=("$1")
            ;;
        -p|--port)
            shift
            [ -z "${1-}" ] && usage
            WEB_PORT="$1"
            ;;
        -r|--redis-port)
            shift
            [ -z "${1-}" ] && usage
            REDIS_PORT="$1"
            ;;
        -P|--password)
            shift
            [ -z "${1-}" ] && usage
            ADMIN_PASSWORD="$1"
            ;;
        -c|--config-dir)
            shift
            [ -z "${1-}" ] && usage
            CONFIG_DIR="$1"
            ;;
        -d|--data-dir)
            shift
            [ -z "${1-}" ] && usage
            DATA_DIR="$1"
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
    shift
done

# Create directories
for d in "$CONFIG_DIR" "$DATA_DIR/ntopng" "$REDIS_DATA_DIR"; do
  mkdir -p "$d"
done

# Build interface arguments
IFS_ARGS=()
for iface in "${INTERFACES[@]}"; do
    IFS_ARGS+=("-i" "$iface")
done

# Remove old containers if exist
for old_container in "$CONTAINER_NAME" "$REDIS_NAME"; do
    if docker ps -a --format '{{.Names}}' | grep -q "^${old_container}$"; then
        echo "[+] Removing existing container: $old_container"
        docker rm -f "$old_container"
    fi
done

# Start Redis container first (with persistence and frequent saves)
echo "[+] Starting Redis container: $REDIS_NAME on port $REDIS_PORT"
docker run -d \
    --name "$REDIS_NAME" \
    --net=host \
    --restart=unless-stopped \
    -p "$REDIS_PORT:$REDIS_PORT" \
    -v "$REDIS_DATA_DIR":/data \
    redis:alpine \
    redis-server --port "$REDIS_PORT" --save 60 1 --save 900 10 --appendonly no

# Wait for Redis to be ready
echo "[+] Waiting for Redis ($REDIS_PORT) to be ready..."
sleep 3
docker exec "$REDIS_NAME" redis-cli -p "$REDIS_PORT" ping || { echo "Redis failed to start"; exit 1; }

# Start ntopng (connected to Redis)
echo "[+] Starting ntopng container on interfaces: ${INTERFACES[*]}"
docker run -d \
    --name "$CONTAINER_NAME" \
    --net=host \
    --restart=unless-stopped \
    -v "$CONFIG_DIR":/etc/ntopng \
    -v "$DATA_DIR/ntopng":/var/lib/ntopng/ntopng \
    -e "NTOPNG_ADMIN_PASSWORD=$ADMIN_PASSWORD" \
    ntop/ntopng:latest \
    -r "localhost:$REDIS_PORT" \
    "${IFS_ARGS[@]}" \
    -w "$WEB_PORT"

echo "[✓] ntopng + Redis are running!"
echo "Access the web UI at http://localhost:$WEB_PORT"
