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

#
# Robust installer for Zabbix repo + agent across distros.
# Downloads the repo package to /tmp then installs via rpm/dpkg as appropriate.
#
function install_zabbix_repo_and_agent() {
  detect_os

  # simple arch mapping for repo path
  case "$(uname -m)" in
    x86_64|amd64) arch="x86_64" ;;
    aarch64|arm64) arch="aarch64" ;;
    *) arch="$(uname -m)" ;; # fallback - may or may not exist on repo
  esac

  case "${OS_ID}" in
    debian|ubuntu|raspbian)
      ## Debian-family repo
      if ! command -v wget >/dev/null 2>&1 && ! command -v curl >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y wget ca-certificates
      fi

      base_url="https://repo.zabbix.com/zabbix/${ZBX_VERSION}/debian/pool/main/z/zabbix-release/"
      deb_pkg="zabbix-release_latest+${OS_ID}${OS_VERSION_ID}_all.deb"

      echo "Installing Zabbix repo: ${base_url}${deb_pkg}"
      tmpfile="/tmp/zabbix-release.deb"
      if command -v curl >/dev/null 2>&1; then
        sudo rm -f "${tmpfile}" || true
        curl -fL -o "${tmpfile}" "${base_url}${deb_pkg}"
      else
        wget -O "${tmpfile}" "${base_url}${deb_pkg}"
      fi

      sudo dpkg -i "${tmpfile}"
      sudo apt-get update -y

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

    rhel|centos|rocky|alma|ol|oraclelinux|amzn|amazon|fedora)
      ## RHEL-family uses repo.zabbix.com/zabbix/<VER>/rhel/<EL_MAJOR>/<arch>/zabbix-release-...noarch.rpm
      base_url="https://repo.zabbix.com/zabbix/${ZBX_VERSION}/rhel"

      # parse a numeric major if possible
      raw_major="${OS_VERSION_ID%%.*}"
      if [[ "${OS_ID}" == "fedora" ]]; then
        # Map Fedora releases to closest EL major
        # Fedora 40+ -> EL9; else EL8 (tunable)
        if [[ "${raw_major}" =~ ^[0-9]+$ ]] && (( raw_major >= 40 )); then
          el_major=9
        else
          el_major=8
        fi
      else
        if [[ "${raw_major}" =~ ^[0-9]+$ ]]; then
          # Amazon/Oracle often report odd values; normalize common cases
          if [[ "${OS_ID}" =~ ^(amzn|amazon)$ ]]; then
            # Amazon Linux 2 -> use EL7/8? modern Amazon Linux 2022 -> EL8/9 mapping is distro-specific; choose EL9 if unknown
            if (( raw_major >= 2022 )); then
              el_major=9
            else
              el_major=8
            fi
          elif [[ "${OS_ID}" =~ ^(ol|oraclelinux)$ ]]; then
            # Oracle Linux version may be like 8.6 -> keep 8/9 mapping
            if (( raw_major >= 9 )); then el_major=9; else el_major=8; fi
          else
            # default: attempt to map numeric raw_major directly if small (7/8/9). Otherwise fallback to 9.
            if (( raw_major >= 9 )); then el_major=9
            elif (( raw_major >= 8 )); then el_major=8
            else el_major=8
            fi
          fi
        else
          el_major=9
        fi
      fi

      # Candidate EL majors to try (try chosen first, then fallback 9 then 8)
      candidates=("${el_major}")
      [[ "${el_major}" != "9" ]] && candidates+=("9")
      [[ "${el_major}" != "8" ]] && candidates+=("8")

      tmpfile="/tmp/zabbix-release.rpm"
      success=false
      for m in "${candidates[@]}"; do
        repo_rpm_url="${base_url}/${m}/${arch}/zabbix-release-latest-${ZBX_VERSION}.el${m}.noarch.rpm"
        echo "Trying repo URL: ${repo_rpm_url}"
        # download with curl or wget to check for 200
        if command -v curl >/dev/null 2>&1; then
          if curl -fL -o "${tmpfile}" "${repo_rpm_url}"; then
            success=true
            break
          else
            rm -f "${tmpfile}" || true
            echo "  -> not found or failed (curl)"
          fi
        elif command -v wget >/dev/null 2>&1; then
          if wget -O "${tmpfile}" "${repo_rpm_url}"; then
            success=true
            break
          else
            rm -f "${tmpfile}" || true
            echo "  -> not found or failed (wget)"
          fi
        else
          echo "curl/wget not found; installing curl"
          if command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y curl
          else
            sudo yum install -y curl
          fi
          # then retry this iteration
          if curl -fL -o "${tmpfile}" "${repo_rpm_url}"; then
            success=true
            break
          else
            rm -f "${tmpfile}" || true
            echo "  -> not found after installing curl"
          fi
        fi
      done

      if [[ "${success}" != "true" ]]; then
        echo "[ERROR] Could not download any zabbix-release RPM for ${OS_ID} (tried: ${candidates[*]} / arch=${arch})." >&2
        exit 1
      fi

      echo "Installing Zabbix repo package from ${tmpfile}"
      sudo rpm -Uvh "${tmpfile}"

      ## Install agent2 if possible
      if command -v dnf >/dev/null 2>&1; then
        sudo dnf clean all || true
        sudo dnf install -y zabbix-agent2 || sudo dnf install -y zabbix-agent
      else
        sudo yum clean all || true
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
        echo "zypper not available, cannot install Zabbix on ${OS_ID}" >&2
        exit 1
      fi
      ;;

    *)
      echo "Unknown OS_ID=${OS_ID}, attempting generic installation."

      if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y zabbix-agent2 || sudo apt-get install -y zabbix-agent
      elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y zabbix-agent2 || sudo dnf install -y zabbix-agent
      elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y zabbix-agent2 || sudo yum install -y zabbix-agent
      elif command -v zypper >/dev/null 2>&1; then
        sudo zypper -n install zabbix-agent2 || sudo zypper -n install zabbix-agent
      else
        echo "No supported package manager found."
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
