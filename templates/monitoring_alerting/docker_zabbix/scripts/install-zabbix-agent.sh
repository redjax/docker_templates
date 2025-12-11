#!/usr/bin/env bash
set -euo pipefail

## Zabbix server address (IP or FQDN)
SERVER_ADDRESS=""
## Zabix server port (default: 10051)
SERVER_PORT="10051"
## Hostname for agent (what shows in the webui)
AGENT_HOSTNAME=""
## Tags/metadata for the agent
#  Set up actions in the Zabbix UI that react to agent metadata
METADATA="autoregister"
## Zabbix agent version
VERSION="7.4"
## Registration key for the agent, created in the Zabbix server UI
AGENT_REG_KEY=""
## Set to true if server uses HTTPS
ENABLE_TLS="false"
## Path where agent pre-shared key will be generated 
PSK_FILE="/etc/zabbix/zabbix_agentd.psk"

usage() {
    cat <<EOF
Usage: $0 [options]

Options:
  -s, --server <host>          Zabbix Server hostname or IP
  -p, --port <port>            Zabbix ServerActive port (default: 10051)
  -h, --agent-hostname <name>  Optional agent hostname override
  -m, --metadata <string>      Metadata string (default: autoregister)
  -v, --version <ver>          Zabbix version (e.g. 6.4)
  -k, --registration-key <key> Optional autoregistration key
  -e, --enable-tls             Enable TLS PSK encryption
  -H, --help                   Show this help
EOF
    exit 1
}

## Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        -s|--server) SERVER_ADDRESS="$2"; shift 2;;
        -p|--port) SERVER_PORT="$2"; shift 2;;
        -h|--agent-hostname) AGENT_HOSTNAME="$2"; shift 2;;
        -m|--metadata) METADATA="$2"; shift 2;;
        -v|--version) VERSION="$2"; shift 2;;
        -k|--registration-key) AGENT_REG_KEY="$2"; shift 2;;
        -e|--enable-tls) ENABLE_TLS="true"; shift;;
        -H|--help) usage;;
        *) echo "Unknown option: $1"; usage;;
    esac
done

## Validate inputs
[[ -z "$SERVER_ADDRESS" ]] && read -rp "Zabbix server hostname/IP: " SERVER_ADDRESS
[[ -z "$SERVER_PORT" ]] && read -rp "Zabbix server port (default 10051): " SERVER_PORT
SERVER_PORT="${SERVER_PORT:-10051}"

[[ -z "$AGENT_HOSTNAME" ]] && AGENT_HOSTNAME=""
[[ -z "$METADATA" ]] && METADATA="autoregister"
[[ -z "$VERSION" ]] && read -rp "Zabbix version (e.g. 7.4): " VERSION

if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS="$ID"
else
    echo "Cannot detect OS."
    exit 1
fi

install_agent() {
    echo "Downloading Zabbix agent for OS: $OS"
    case "$OS" in
        ubuntu|debian)
	    CODENAME=$(lsb_release -cs)
	    URL="https://repo.zabbix.com/zabbix/$VERSION/${ID}/pool/main/z/zabbix-release/zabbix-release_${VERSION}-1+${CODENAME}_all.deb"
	    
	    echo "Downloading Zabbix release package from $URL"
	    wget -O /tmp/zabbix-release.deb "$URL"
	    
            echo "Installing Zabbix agent"
	    sudo dpkg -i /tmp/zabbix-release.deb
            sudo apt update
            sudo apt install -y zabbix-agent2
            
            ;;
        centos|rhel|rocky|almalinux)
            rpm -Uvh \
                "https://repo.zabbix.com/zabbix/$VERSION/rhel/$(rpm -E %rhel)/x86_64/zabbix-release-${VERSION}-1.el$(rpm -E %rhel).noarch.rpm"
            sudo dnf install -y zabbix-agent2
            ;;
        fedora)
            rpm -Uvh \
                "https://repo.zabbix.com/zabbix/$VERSION/rhel/9/x86_64/zabbix-release-${VERSION}-1.el9.noarch.rpm"
            sudo dnf install -y zabbix-agent2
            ;;
        opensuse*|sles)
            rpm -Uvh \
                "https://repo.zabbix.com/zabbix/$VERSION/sles/15/x86_64/zabbix-release-${VERSION}-1.sles15.noarch.rpm"
            sudo zypper install -y zabbix-agent2
            ;;
        arch)
            sudo pacman -Sy --noconfirm zabbix-agent2
            ;;
        *)
            echo "Unsupported OS: $OS"
            exit 1
            ;;
    esac
}

install_agent

if [[ "$ENABLE_TLS" == "true" ]]; then
    mkdir -p /etc/zabbix

    openssl rand -hex 32 > "$PSK_FILE"
    chmod 600 "$PSK_FILE"
fi

CONF="/etc/zabbix/zabbix_agent2.conf"

cat > "$CONF" <<EOF
Server=$SERVER_ADDRESS
ServerActive=$SERVER_ADDRESS:$SERVER_PORT
HostMetadata=$METADATA
Hostname=$AGENT_HOSTNAME
EOF

if [[ -n "$AGENT_REG_KEY" ]]; then
    echo "HostRegistrationKey=$AGENT_REG_KEY" >> "$CONF"
fi

if [[ "$ENABLE_TLS" == "true" ]]; then
    cat >> "$CONF" <<EOF
TLSConnect=psk
TLSAccept=psk
TLSPSKFile=$PSK_FILE
TLSPSKIdentity=agent_${HOSTNAME:-$(hostname)}
EOF
fi

sudo systemctl enable zabbix-agent2
sudo systemctl restart zabbix-agent2

if [[ "$ENABLE_TLS" == "true" ]]; then
    echo "PSK identity: agent_${HOSTNAME:-$(hostname)}"
    echo "PSK (add this in the Zabbix sever webUI):"

    cat "$PSK_FILE"
fi

