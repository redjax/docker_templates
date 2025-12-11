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

usage() {
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
detect_os() {
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

install_zabbix_repo_and_agent() {
  detect_os

  case "${OS_ID}" in
    debian|ubuntu|raspbian)
      ## Use official Zabbix repo package for Debian/Ubuntu/Raspbian. 
      if ! command -v wget >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y wget
      fi

      base_url="https://repo.zabbix.com/zabbix/${ZBX_VERSION}/release"

      case "${OS_ID}" in
        debian)   repo_path="debian";;
        ubuntu)   repo_path="ubuntu";;
        raspbian) repo_path="raspbian";;
      esac

      ## Use generic latest release package for that distro series.
      repo_pkg_url="${base_url}/${repo_path}/pool/main/z/zabbix-release/zabbix-release_latest+${OS_ID}${OS_VERSION_ID}_all.deb"
      echo "Downloading Zabbix repo package: ${repo_pkg_url}"
      
      wget -O /tmp/zabbix-release.deb "${repo_pkg_url}"
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

    rhel|centos|rocky|alma|ol|oraclelinux|amazon|amzn)
      ## RHEL-like family (RHEL, CentOS, Rocky, Alma, Oracle, Amazon Linux).
      base_url="https://repo.zabbix.com/zabbix/${ZBX_VERSION}/release"
      
      case "${OS_ID}" in
        rocky)
            repo_path="rocky"
            ;;
        alma)
            repo_path="alma"
            ;;
        centos)
            repo_path="centos"
            ;;
        rhel)
            repo_path="rhel"
            ;;
        ol|oraclelinux)
            repo_path="oracle"
            ;;

        ## Amazon Linux maps to RHEL builds.
        amazon|amzn)
            repo_path="rhel"
            ;;
        *)
          ## Fallback to generic rhel path
          repo_path="rhel"
          ;;
      esac

      ## Major version for elN
      major="${OS_VERSION_ID%%.*}"
      repo_rpm_url="${base_url}/${repo_path}/${major}/noarch/zabbix-release-latest-${ZBX_VERSION}.el${major}.noarch.rpm"
      
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
      ## SUSE family: use Zabbix repo for SLES if available, otherwise distro package. 
      if command -v zypper >/dev/null 2>&1; then
        
        ## Try vendor repo first; many SUSE builds ship zabbix packages.
        if ! sudo zypper -n install zabbix-agent2; then
          sudo zypper -n install zabbix-agent || true
        fi
        
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
      ## Generic fallback: use distro repos (Debian-like, RHEL-like, SUSE-like). [web:22]
      echo "Unknown or unsupported OS_ID=${OS_ID}, attempting generic install from OS repos."
      if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y zabbix-agent2 || sudo apt-get install -y zabbix-agent

        if [[ -f /etc/zabbix/zabbix_agent2.conf ]]; then
          ZBX_AGENT_CONF="/etc/zabbix/zabbix_agent2.conf"
          ZBX_AGENT_SVC="zabbix-agent2"
        else
          ZBX_AGENT_CONF="/etc/zabbix/zabbix_agentd.conf"
          ZBX_AGENT_SVC="zabbix-agent"
        fi

      elif command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1; then

        if command -v dnf >/dev/null 2>&1; then
          sudo dnf install -y zabbix-agent2 || sudo dnf install -y zabbix-agent
        else
          sudo yum install -y zabbix-agent2 || sudo yum install -y zabbix-agent
        fi

        if [[ -f /etc/zabbix/zabbix_agent2.conf ]]; then
          ZBX_AGENT_CONF="/etc/zabbix/zabbix_agent2.conf"
          ZBX_AGENT_SVC="zabbix-agent2"
        else
          ZBX_AGENT_CONF="/etc/zabbix/zabbix_agentd.conf"
          ZBX_AGENT_SVC="zabbix-agent"
        fi
      elif command -v zypper >/dev/null 2>&1; then
        sudo zypper -n install zabbix-agent2 || sudo zypper -n install zabbix-agent

        if [[ -f /etc/zabbix/zabbix_agent2.conf ]]; then
          ZBX_AGENT_CONF="/etc/zabbix/zabbix_agent2.conf"
          ZBX_AGENT_SVC="zabbix-agent2"
        else
          ZBX_AGENT_CONF="/etc/zabbix/zabbix_agentd.conf"
          ZBX_AGENT_SVC="zabbix-agent"
        fi

      else
        echo "No supported package manager found; cannot install Zabbix agent." >&2
        exit 1
      fi
      ;;
  esac
}

configure_agent() {
  local conf="${ZBX_AGENT_CONF}"

  if [[ ! -f "${conf}" ]]; then
    echo "Zabbix agent config not found at ${conf}." >&2
    exit 1
  fi

  sudo cp -a "${conf}" "${conf}.bak.$(date +%s)"

  ## Basic settings (Server for passive, ServerActive for active). 
  sudo sed -i \
    -e "s|^#\?Hostname=.*|Hostname=${ZBX_HOSTNAME}|" \
    -e "s|^#\?Server=.*|Server=${ZBX_SERVER}|" \
    -e "s|^#\?ServerActive=.*|ServerActive=${ZBX_SERVER}:${ZBX_PORT}|" \
    "${conf}"

  ## Metadata (create if not present). 
  if [[ -n "${ZBX_METADATA_STR}" ]]; then
    if grep -qE '^#?HostMetadata=' "${conf}"; then
      sudo sed -i "s|^#\?HostMetadata=.*|HostMetadata=${ZBX_METADATA_STR}|" "${conf}"
    else
      echo "HostMetadata=${ZBX_METADATA_STR}" | sudo tee -a "${conf}" >/dev/null
    fi
  fi

  ## Auto-registration key (HostRegistrationKey). 
  if [[ -n "${ZBX_REG_KEY}" ]]; then
    if grep -qE '^#?HostRegistrationKey=' "${conf}"; then
      sudo sed -i "s|^#\?HostRegistrationKey=.*|HostRegistrationKey=${ZBX_REG_KEY}|" "${conf}"
    else
      echo "HostRegistrationKey=${ZBX_REG_KEY}" | sudo tee -a "${conf}" >/dev/null
    fi
  fi

  ## TLS configuration (PSK). 
  if [[ "${ZBX_ENABLE_TLS}" == "true" ]]; then
    read -rp "Enter TLS PSK identity: " TLS_ID
    read -rsp "Enter TLS PSK (hex string): " TLS_PSK

    echo ""

    local psk_file="/etc/zabbix/agent.psk"

    echo "${TLS_PSK}" | sudo tee "${psk_file}" >/dev/null

    sudo chmod 600 "${psk_file}"
    sudo chown root:root "${psk_file}" || true

    ## For both zabbix_agentd.conf and zabbix_agent2.conf the directives are the same. 
    if grep -qE '^#?TLSConnect=' "${conf}"; then
      sudo sed -i "s|^#\?TLSConnect=.*|TLSConnect=psk|" "${conf}"
    else
      echo "TLSConnect=psk" | sudo tee -a "${conf}" >/dev/null
    fi
    
    if grep -qE '^#?TLSAccept=' "${conf}"; then
      sudo sed -i "s|^#\?TLSAccept=.*|TLSAccept=psk|" "${conf}"
    else
      echo "TLSAccept=psk" | sudo tee -a "${conf}" >/dev/null
    fi
    
    if grep -qE '^#?TLSPSKIdentity=' "${conf}"; then
      sudo sed -i "s|^#\?TLSPSKIdentity=.*|TLSPSKIdentity=${TLS_ID}|" "${conf}"
    else
      echo "TLSPSKIdentity=${TLS_ID}" | sudo tee -a "${conf}" >/dev/null
    fi
    
    if grep -qE '^#?TLSPSKFile=' "${conf}"; then
      sudo sed -i "s|^#\?TLSPSKFile=.*|TLSPSKFile=${psk_file}|" "${conf}"
    else
      echo "TLSPSKFile=${psk_file}" | sudo tee -a "${conf}" >/dev/null
    fi
  fi
}

restart_agent() {
  if command -v systemctl >/dev/null 2>&1; then
    sudo systemctl restart "${ZBX_AGENT_SVC}"
    sudo systemctl enable "${ZBX_AGENT_SVC}" || true
  else
    sudo service "${ZBX_AGENT_SVC}" restart || true
  fi
}

main() {
  install_zabbix_repo_and_agent
  configure_agent
  restart_agent

  echo "Zabbix agent installation complete."
  echo "  Server:        ${ZBX_SERVER}"
  echo "  ServerActive:  ${ZBX_SERVER}:${ZBX_PORT}"
  echo "  Hostname:      ${ZBX_HOSTNAME}"

  [[ -n "${ZBX_METADATA_STR}" ]] && echo "  Metadata:      ${ZBX_METADATA_STR}"
  [[ "${ZBX_ENABLE_TLS}" == "true" ]] && echo "  TLS:           PSK enabled"
  [[ -n "${ZBX_REG_KEY}" ]] && echo "  Reg key:      ${ZBX_REG_KEY}"
}

main "$@"
