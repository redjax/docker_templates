#!/usr/bin/env bash
set -euo pipefail

## Defaults
ZBX_VERSION="7.4"
ZBX_SERVER=""
ZBX_PORT="10051"
ZBX_HOSTNAME=""
ZBX_METADATA=()
ZBX_ENABLE_TLS="false"
ZBX_REG_KEY=""

function usage() {
cat <<EOF
Usage: $0 -s <server> [options]

Options:
  -s, --server <ip|fqdn>   Zabbix server (required)
  -p, --port <port>        ServerActive port (default: 10051)
  -h, --hostname <name>    Hostname to report (default: system hostname)
  -m, --metadata <value>  Metadata (repeatable)
  -v, --version <ver>     Zabbix version (default: 7.4)
      --enable-tls        Enable PSK TLS
  -k, --registration-key  Host registration key
      --help              Show this help
EOF
}

## Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--server) ZBX_SERVER="$2"; shift 2 ;;
    -p|--port) ZBX_PORT="$2"; shift 2 ;;
    -h|--hostname) ZBX_HOSTNAME="$2"; shift 2 ;;
    -m|--metadata) ZBX_METADATA+=("$2"); shift 2 ;;
    -v|--version) ZBX_VERSION="$2"; shift 2 ;;
    --enable-tls) ZBX_ENABLE_TLS="true"; shift ;;
    -k|--registration-key) ZBX_REG_KEY="$2"; shift 2 ;;
    --help) usage; exit 0 ;;
    *) echo "Unknown arg: $1"; usage; exit 1 ;;
  esac
done

if [[ -z "$ZBX_SERVER" ]]; then
  echo "Missing a server address"

  while true; do
    read -r -p "Server IP or FQDN: " server_input
    echo ""

    if [[ -z "$server_input" ]]; then
      echo "You must input a server IP or FQDN."
    else
      ZBX_SERVER="$server_input"
      echo "Using server address: $ZBX_SERVER"
      break
    fi
  done
fi

## Set agent hostname
[[ -z "$ZBX_HOSTNAME" ]] && ZBX_HOSTNAME="$(hostname -f 2>/dev/null || hostname)"

META_STR="${ZBX_METADATA[*]:-}"

## Detect OS
. /etc/os-release
OS_ID="$ID"
OS_VERSION_ID="${VERSION_ID:-}"

function install_agent() {
  case "$OS_ID" in
    fedora)
      echo "[INFO] Fedora detected — using Fedora repos"
      sudo dnf install -y zabbix-agent2
      ;;
    rhel|centos|rocky|alma|ol|oraclelinux)
      major="${OS_VERSION_ID%%.*}"
      repo_url="https://repo.zabbix.com/zabbix/${ZBX_VERSION}/rhel/${major}/x86_64/zabbix-release-latest-${ZBX_VERSION}.el${major}.noarch.rpm"
      
      echo "[INFO] Installing Zabbix repo: $repo_url"
      
      sudo rpm -Uvh "$repo_url"
      sudo dnf install -y zabbix-agent2
      ;;
    debian|ubuntu)
      echo "[INFO] Debian-based detected"
      
      sudo apt-get update
      sudo apt-get install -y wget gnupg
      
      deb="zabbix-release_latest+${OS_ID}${OS_VERSION_ID}_all.deb"
      url="https://repo.zabbix.com/zabbix/${ZBX_VERSION}/debian/pool/main/z/zabbix-release/${deb}"
      
      wget -O /tmp/zabbix-release.deb "$url"
      
      sudo dpkg -i /tmp/zabbix-release.deb
      sudo apt-get update
      sudo apt-get install -y zabbix-agent2
      ;;
    *)
      echo "[ERROR] Unsupported OS: $OS_ID"
      exit 1
      ;;
  esac
}

function configure_agent() {
  CONF="/etc/zabbix/zabbix_agent2.conf"
  SVC="zabbix-agent2"

  sudo useradd --system --home /var/lib/zabbix --shell /sbin/nologin zabbix 2>/dev/null || true
  sudo mkdir -p /var/log/zabbix /run/zabbix
  sudo chown zabbix:zabbix /var/log/zabbix /run/zabbix

  sudo cp -a "$CONF" "$CONF.bak.$(date +%s)" || true

  TLS_BLOCK=""
  if [[ "$ZBX_ENABLE_TLS" == "true" ]]; then
    read -rp "TLS PSK Identity: " TLS_ID
    read -rsp "TLS PSK (hex): " TLS_PSK; echo
    echo "$TLS_PSK" | sudo tee /etc/zabbix/zabbix_agent.psk >/dev/null
    sudo chmod 600 /etc/zabbix/zabbix_agent.psk
    sudo chown zabbix:zabbix /etc/zabbix/zabbix_agent.psk
    TLS_BLOCK="
TLSConnect=psk
TLSAccept=psk
TLSPSKIdentity=${TLS_ID}
TLSPSKFile=/etc/zabbix/zabbix_agent.psk"
  fi

  sudo tee "$CONF" >/dev/null <<EOF
### Generated $(date)
Hostname=${ZBX_HOSTNAME}
Server=${ZBX_SERVER}
ServerActive=${ZBX_SERVER}:${ZBX_PORT}
HostMetadata=${META_STR}
HostRegistrationKey=${ZBX_REG_KEY}
ListenPort=10050
ListenIP=0.0.0.0
LogFile=/var/log/zabbix/zabbix_agent2.log
PidFile=/run/zabbix/zabbix_agent2.pid
Timeout=30
${TLS_BLOCK}
Include=/etc/zabbix/zabbix_agent2.d/
EOF

  sudo chown zabbix:zabbix "$CONF"
  sudo chmod 644 "$CONF"
}

function start_agent() {
  sudo systemctl daemon-reload
  sudo systemctl enable zabbix-agent2
  sudo systemctl restart zabbix-agent2

  sleep 2
  systemctl is-active --quiet zabbix-agent2 || {
    echo "[ERROR] Agent failed to start"
    sudo journalctl -u zabbix-agent2 -n 50 --no-pager
    exit 1
  }
}

## Do agent install
install_agent
configure_agent
start_agent

echo ""
echo "Zabbix Agent installed"
echo "  Server:   ${ZBX_SERVER}:${ZBX_PORT}"
echo "  Hostname: ${ZBX_HOSTNAME}"
echo "  Service:  zabbix-agent2"
echo ""
echo "Check:"
echo "  systemctl status zabbix-agent2"
