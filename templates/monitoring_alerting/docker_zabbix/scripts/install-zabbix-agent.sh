#!/usr/bin/env bash
set -euo pipefail

## Defaults
ZBX_VERSION="7.4"
ZBX_SERVER=""
ZBX_PORT="10051"
ZBX_HOSTNAME=""
ZBX_METADATA=(autoregister)
ZBX_ENABLE_TLS="false"
ZBX_REG_KEY=""

function usage() {
  cat <<EOF
Usage: $0 [options]

Options:
  -s, --server            Zabbix server IP or FQDN (required, will prompt if omitted)
  -p, --port              Zabbix server active port (default: 10051)
  -h, --agent-hostname    Hostname to report to Zabbix (default: system hostname)
  -m, --metadata          Agent metadata (repeatable; multiple values allowed)
  -v, --agent-version     Zabbix agent major version (default: 7.4)
      --enable-tls        Enable PSK-based TLS (prompts for identity and PSK)
  -k, --registration-key  Auto-registration key
      --help              Show this help and exit

Example:
  $0 -s zabbix.example.com -p 10051 -m env=prod -m role=web --enable-tls
EOF
}

## Simple arg parsing
while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--server)
      ZBX_SERVER="$2"
      shift 2
      ;;
    -p|--port)
      ZBX_PORT="$2"
      shift 2
      ;;
    -h|--agent-hostname)
      ZBX_HOSTNAME="$2"
      shift 2
      ;;
    -m|--metadata)
      ZBX_METADATA+=("$2")
      shift 2
      ;;
    -v|--agent-version)
      ZBX_VERSION="$2"
      shift 2
      ;;
    --enable-tls)
      ZBX_ENABLE_TLS="true"
      shift 1
      ;;
    -k|--registration-key)
      ZBX_REG_KEY="$2"
      shift 2
      ;;
    --help|-help|-hhelp)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

## Prompt for server if missing
if [[ -z "${ZBX_SERVER}" ]]; then
  read -rp "Enter Zabbix server IP/FQDN: " ZBX_SERVER
fi

if [[ -z "${ZBX_SERVER}" ]]; then
  echo "Zabbix server is required." >&2
  exit 1
fi

## Default hostname
if [[ -z "${ZBX_HOSTNAME}" ]]; then
  ZBX_HOSTNAME="$(hostname -f 2>/dev/null || hostname)"
fi

## Build metadata string (space-separated, as Zabbix expects a single value)
ZBX_METADATA_STR=""
if [[ ${#ZBX_METADATA[@]} -gt 0 ]]; then
  ZBX_METADATA_STR="${ZBX_METADATA[*]}"
fi

## Detect OS
function detect_os() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS_ID="${ID:-}"
    OS_ID_LIKE="${ID_LIKE:-}"
    OS_VERSION_ID="${VERSION_ID:-}"
  else
    echo "Cannot detect OS (no /etc/os-release)." >&2
    exit 1
  fi
}

function install_zabbix_repo_and_agent() {
  detect_os

  case "${OS_ID}" in
    debian|ubuntu|raspbian)
      ## Use official Zabbix repo package for Debian/Ubuntu/Raspbian. 
      if ! command -v wget >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y wget
      fi

      base_url="https://repo.zabbix.com/zabbix/${ZBX_VERSION}/debian/pool/main/z/zabbix-release/"
      wget -O /tmp/zabbix-release.deb "${base_url}zabbix-release_latest+${OS_ID}${OS_VERSION_ID}_all.deb"
      sudo dpkg -i /tmp/zabbix-release.deb
      sudo apt-get update
      
      ## Prefer agent2 if available, fall back to agent
      if apt-cache show zabbix-agent2 >/dev/null 2>&1; then
        sudo apt-get install -y zabbix-agent2
        ZBX_AGENT_CONF="/etc/zabbix/zabbix_agent2.conf"
        ZBX_AGENT_SVC="zabbix-agent2"
      else
        sudo apt-get install -y zabbix-agent
        ZBX_AGENT_CONF="/etc/zabbix/zabbix_agentd.conf"
        ZBX_AGENT_SVC="zabbix-agent"
      fi
      ;;

    rhel|fedora|centos|rocky|alma|ol|oraclelinux|amazon|amzn)
      ## RHEL-like family (RHEL, CentOS, Rocky, Alma, Oracle, Amazon Linux).
      base_url="https://repo.zabbix.com/zabbix/${ZBX_VERSION}/rhel"
      
      ## Map distro to repo path
      case "${OS_ID}" in
        rocky)    repo_path="rocky" ;;
        alma)     repo_path="alma" ;;
        centos)   repo_path="centos" ;;
        rhel)     repo_path="rhel" ;;
        ol|oraclelinux) repo_path="oracle" ;;
        amazon|amzn)    repo_path="rhel" ;;
        fedora)
          ## Fedora maps to closest RHEL version
          repo_path="rhel/9"
          ;;
        *)
          repo_path="rhel/9"
          ;;
      esac

      ## Install repo RPM
      major="${OS_VERSION_ID%%.*}"
      case "${major}" in
        3[0-9]) el_major="8" ;;
        4[0-2]) el_major="9" ;;
        *)      el_major="9" ;;
      esac
      
      repo_rpm_url="${base_url}/${repo_path}/${el_major}/noarch/zabbix-release-latest-${ZBX_VERSION}.el${el_major}.noarch.rpm"
      echo "Installing Zabbix repo from: ${repo_rpm_url}"
      
      sudo rpm -Uvh "${repo_rpm_url}" || true
      if command -v dnf >/dev/null 2>&1; then
        sudo dnf clean all
        sudo dnf install -y zabbix-agent2 || sudo dnf install -y zabbix-agent
      else
        sudo yum clean all
        sudo yum install -y zabbix-agent2 || sudo yum install -y zabbix-agent
      fi
      
      if [[ -f /etc/zabbix/zabbix_agent2.conf ]]; then
        ZBX_AGENT_CONF="/etc/zabbix/zabbix_agent2.conf"
        ZBX_AGENT_SVC="zabbix-agent2"
      else
        ZBX_AGENT_CONF="/etc/zabbix/zabbix_agentd.conf"
        ZBX_AGENT_SVC="zabbix-agent"
      fi
      ;;

    sles|suse|opensuse*)
      if command -v zypper >/dev/null 2>&1; then
        sudo zypper -n install zabbix-agent2 || sudo zypper -n install zabbix-agent
        if [[ -f /etc/zabbix/zabbix_agent2.conf ]]; then
          ZBX_AGENT_CONF="/etc/zabbix/zabbix_agent2.conf"
          ZBX_AGENT_SVC="zabbix-agent2"
        else
          ZBX_AGENT_CONF="/etc/zabbix/zabbix_agentd.conf"
          ZBX_AGENT_SVC="zabbix-agent"
        fi
      else
        echo "zypper not found; cannot install Zabbix agent on ${OS_ID}." >&2
        exit 1
      fi
      ;;

    *)
      echo "Unknown OS_ID=${OS_ID}, attempting generic install from OS repos."

      if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y zabbix-agent2 || sudo apt-get install -y zabbix-agent
      elif command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1; then
        if command -v dnf >/dev/null 2>&1; then
          sudo dnf install -y zabbix-agent2 || sudo dnf install -y zabbix-agent
        else
          sudo yum install -y zabbix-agent2 || sudo yum install -y zabbix-agent
        fi
      elif command -v zypper >/dev/null 2>&1; then
        sudo zypper -n install zabbix-agent2 || sudo zypper -n install zabbix-agent
      else
        echo "No supported package manager found." >&2
        exit 1
      fi
      
      if [[ -f /etc/zabbix/zabbix_agent2.conf ]]; then
        ZBX_AGENT_CONF="/etc/zabbix/zabbix_agent2.conf"
        ZBX_AGENT_SVC="zabbix-agent2"
      else
        ZBX_AGENT_CONF="/etc/zabbix/zabbix_agentd.conf"
        ZBX_AGENT_SVC="zabbix-agent"
      fi
      ;;
  esac

  export ZBX_AGENT_SVC
}

function fix_fedora_service() {
  ## Fedora/RHEL fix: Ensure service unit paths are correct and reload
  if command -v systemctl >/dev/null 2>&1 && [[ "${OS_ID}" == @(fedora|rhel|centos|rocky|alma) ]]; then
    svc_unit="/usr/lib/systemd/system/${ZBX_AGENT_SVC}.service"
    
    ## Fix binary path if needed (some Fedora builds use /usr/bin)
    if grep -q "/usr/sbin/${ZBX_AGENT_SVC}" "${svc_unit}" 2>/dev/null && \
       [[ ! -x /usr/sbin/${ZBX_AGENT_SVC} && -x /usr/bin/${ZBX_AGENT_SVC} ]]; then
      echo "[INFO] Fixing ExecStart binary path for ${ZBX_AGENT_SVC}..."
      sudo sed -i "s|/usr/sbin/${ZBX_AGENT_SVC}|/usr/bin/${ZBX_AGENT_SVC}|g" "${svc_unit}"
    fi
    
    ## Ensure config condition exists
    if ! grep -q "ConditionPathExists=" "${svc_unit}" 2>/dev/null; then
      echo "[INFO] Adding config existence check to ${ZBX_AGENT_SVC} service..."
      sudo systemctl edit --full "${ZBX_AGENT_SVC}" >/dev/null 2>&1 || true
    fi
    
    sudo systemctl daemon-reload
  fi
}

function configure_agent() {
  local conf="${ZBX_AGENT_CONF}"

  # Detect agent type
  if [[ -f /etc/zabbix/zabbix_agent2.conf ]]; then
    conf="/etc/zabbix/zabbix_agent2.conf"
    ZBX_AGENT_SVC="zabbix-agent2"
  elif [[ -f /etc/zabbix/zabbix_agentd.conf ]]; then
    conf="/etc/zabbix/zabbix_agentd.conf"
    ZBX_AGENT_SVC="zabbix-agent"
  else
    echo "No Zabbix agent config found." >&2
    exit 1
  fi

  ## Create zabbix user/group
  sudo useradd --system --home-dir /var/lib/zabbix --shell /sbin/nologin zabbix || true
  sudo mkdir -p /var/log/zabbix /run/zabbix /var/lib/zabbix
  sudo chown zabbix:zabbix /var/log/zabbix /run/zabbix /var/lib/zabbix

  ## Backup and generate config
  sudo cp -a "${conf}" "${conf}.bak.$(date +%s)" 2>/dev/null || true

  local meta_str=$(IFS=' '; echo "${ZBX_METADATA[*]:-}")
  local tls_block=""
  
  if [[ "${ZBX_ENABLE_TLS}" == "true" ]]; then
    read -rp "Enter TLS PSK identity: " TLS_ID
    read -rsp "Enter TLS PSK (hex string, 32 bytes): " TLS_PSK && echo
    local psk_file="/etc/zabbix/zabbix_agent.psk"
    echo "${TLS_PSK}" | sudo tee "${psk_file}" >/dev/null
    sudo chmod 600 "${psk_file}"
    sudo chown zabbix:zabbix "${psk_file}"
    sudo chmod 755 /var/log/zabbix /run/zabbix /var/lib/zabbix
    
    tls_block="
TLSConnect=psk
TLSAccept=psk
TLSPSKIdentity=${TLS_ID}
TLSPSKFile=${psk_file}"
  fi

  sudo tee "${conf}" >/dev/null << EOF
### Generated by install script on $(date)
Hostname=${ZBX_HOSTNAME}
Server=${ZBX_SERVER}
ServerActive=${ZBX_SERVER}:${ZBX_PORT}
HostMetadata=${meta_str}
HostRegistrationKey=${ZBX_REG_KEY}
ListenPort=10050
ListenIP=0.0.0.0
StartAgents=3
LogFile=/var/log/zabbix/${ZBX_AGENT_SVC}.log
DebugLevel=3
PidFile=/run/zabbix/${ZBX_AGENT_SVC}.pid
Timeout=30
${tls_block}
Include=/etc/zabbix/${ZBX_AGENT_SVC}.d/
EOF

  ## Fix ownership/permissions
  sudo chown zabbix:zabbix "${conf}"
  sudo chmod 644 "${conf}"
  
  echo "Config: ${conf} (owned by zabbix:zabbix)"
}

function restart_agent() {
  fix_fedora_service
  
  if command -v systemctl >/dev/null 2>&1; then
    echo "Starting ${ZBX_AGENT_SVC} service"

    sudo systemctl daemon-reload
    sudo systemctl enable "${ZBX_AGENT_SVC}"
    sudo systemctl reset-failed "${ZBX_AGENT_SVC}" || true
    sudo systemctl start "${ZBX_AGENT_SVC}"
    
    ## Start Zabbix agent service
    for i in {1..5}; do
      sleep 2
      if systemctl is-active --quiet "${ZBX_AGENT_SVC}"; then
        echo "${ZBX_AGENT_SVC} is active and running"
        return 0
      fi
      echo "Waiting for ${ZBX_AGENT_SVC} to start... (${i}/5)"
    done
    
    echo "[ERROR] ${ZBX_AGENT_SVC} failed to start after 10s!"
    
    echo "Service status:"
    sudo systemctl status "${ZBX_AGENT_SVC}" --no-pager -l
    
    echo "Recent logs:"
    sudo journalctl -u "${ZBX_AGENT_SVC}" -n 30 --no-pager -p err

    exit 1
  else
    sudo service "${ZBX_AGENT_SVC}" start || true
    echo "Legacy init: ${ZBX_AGENT_SVC} start attempted"
  fi
}

function main() {
  install_zabbix_repo_and_agent
  configure_agent
  restart_agent

  echo ""
  echo "Zabbix agent installation complete"
  echo "  Config:       ${ZBX_AGENT_CONF}"
  echo "  Service:      ${ZBX_AGENT_SVC}"
  echo "  Server:       ${ZBX_SERVER}:${ZBX_PORT}"
  echo "  Hostname:     ${ZBX_HOSTNAME}"
  
  [[ -n "${ZBX_METADATA_STR}" ]] && echo "  Metadata:     ${ZBX_METADATA_STR}"
  [[ "${ZBX_ENABLE_TLS}" == "true" ]] && echo "  TLS:          PSK enabled"
  [[ -n "${ZBX_REG_KEY}" ]] && echo "  Reg key:      ${ZBX_REG_KEY}"

  echo ""
  echo "Verify: sudo systemctl status ${ZBX_AGENT_SVC}"
  echo "Logs:   sudo journalctl -u ${ZBX_AGENT_SVC} -f"
  echo ""
}

main "$@"
