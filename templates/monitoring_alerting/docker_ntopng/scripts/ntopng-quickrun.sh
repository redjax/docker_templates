#!/usr/bin/env bash
set -euo pipefail

##
# Run ntopng in Docker with configurable options
##

# Default config
INTERFACES=("eth0")
WEB_PORT=3000
ADMIN_PASSWORD="admin"
CONFIG_DIR="./ntopng/config"
DATA_DIR="./ntopng/data"
CONTAINER_NAME="ntopng"

usage() {
    echo "Usage: $0 [-i iface]... [-p web_port] [-w admin_password] [-c config_dir] [-d data_dir]"
    echo "  -i, --interface      Network interface to monitor (can be used multiple times, default: eth0)"
    echo "  -p, --port           Web UI port (default: $WEB_PORT)"
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
            [ -z "$1" ] && usage
            INTERFACES+=("$1")
            ;;
        -p|--port)
            shift
            [ -z "$1" ] && usage
            WEB_PORT="$1"
            ;;
        -P|--password)
            shift
            [ -z "$1" ] && usage
            ADMIN_PASSWORD="$1"
            ;;
        -c|--config-dir)
            shift
            [ -z "$1" ] && usage
            CONFIG_DIR="$1"
            ;;
        -d|--data-dir)
            shift
            [ -z "$1" ] && usage
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

# Create directories if needed
mkdir -p "$CONFIG_DIR"
mkdir -p "$DATA_DIR"

# Build interface arguments
IFS_ARGS=()
for iface in "${INTERFACES[@]}"; do
    IFS_ARGS+=("-i" "$iface")
done

# Remove old container if exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "[+] Removing existing container: $CONTAINER_NAME"
    docker rm -f "$CONTAINER_NAME"
fi

# Run ntopng
echo "[+] Starting ntopng container on interfaces: ${INTERFACES[*]}"
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

echo "[✓] ntopng is running!"
echo "Access the web UI at http://localhost:$WEB_PORT"
