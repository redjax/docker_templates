#!/usr/bin/env bash
set -uo pipefail

FORCE=false

echo ""
echo "[ Zabbix Agent Uninstall ]"
echo " ------------------------ "
echo ""

function usage() {
  echo ""
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -h, --help  Show this help menu"
  echo ""
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -f|--force)
      FORCE=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[ERROR] Invalid option: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ "$FORCE" == "false" ]]; then
    echo "!! WARNING!!"
    echo "   This script will completely remove the Zabbix agent, configuration, & logs"
    echo "   if they are installed on the system."
    echo ""

    while true; do
        read -r -n 1 -p "Do you want to proceed with purging the Zabbix agent? (y/n) " choice
        echo ""

        case $choice in
            [Yy])
            echo "Proceeding with agent uninstall."
            break
            ;;
            [Nn])
            echo "Cancelling uninstall."
            exit 0
            ;;
            *)
            echo "Invalid choice: "$choice", please use 'y' or 'n'."
            ;;
        esac
    done
fi

echo "Detecting OS"

## Detect OS
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    DISTRO_ID=$ID
else
    echo "[ERROR] Cannot detect OS. Exiting."
    exit 1
fi

echo "  Detected distribution: $PRETTY_NAME"
echo ""

## Stop services if running
function stop_service() {
    local svc=$1

    if systemctl list-units --type=service | grep -q "$svc"; then
        echo "[-] Stopping service: $svc"

        sudo systemctl stop "$svc" || true
        sudo systemctl disable "$svc" || true
    fi
}

## Stop agent service if it's running
stop_service zabbix-agent
stop_service zabbix-agent2

## Remove packages
echo ""
echo "[ Remove Zabbix packages ]"
echo ""

case "$DISTRO_ID" in
    ubuntu|debian)
        sudo apt-get remove --purge -y zabbix-agent zabbix-agent2 || true
        sudo apt-get autoremove -y
        ;;
        
    rhel|centos|rocky|almalinux|fedora)
        sudo dnf remove -y zabbix-agent zabbix-agent2 || \
        sudo yum remove -y zabbix-agent zabbix-agent2 || true
        ;;
        
    opensuse*|sles)
        sudo zypper remove -y zabbix-agent zabbix-agent2 || true
        ;;
        
    arch|manjaro)
        sudo pacman -Rns --noconfirm zabbix-agent zabbix-agent2 || true
        ;;
        
    *)
        echo "Unsupported distro: $DISTRO_ID"
        echo "You may need to remove Zabbix manually."
        exit 1
        ;;
esac

echo ""
echo "Package removal complete."
echo

CONFIG_DIR="/etc/zabbix"
LOG_DIR="/var/log/zabbix"

## Check if config dir should be removed, if it exists
if [[ -d "$CONFIG_DIR" ]]; then
    echo "Found configuration directory at $CONFIG_DIR"

    if [[ "$FORCE" == "false" ]]; then

        while true; do

            read -n 1 -r -p "Delete this directory? (y/N): " ans
            echo ""

            if [[ $ans =~ ^[Yy]$ ]]; then
                sudo rm -rf "$CONFIG_DIR"
                echo "Deleted $CONFIG_DIR"

                break
            elif [[ $ans =~ ^[Nn]$ ]]; then
                echo "Keeping dir: $CONFIG_DIR"
                break
            else
                echo "Invalid choice: $ans, please use 'y' or 'n'"
            fi

        done

    else
        sudo rm -rf "$CONFIG_DIR"
        echo "Deleted $CONFIG_DIR"
    fi
fi

if [[ -d "$LOG_DIR" ]]; then
    echo "Found logs at $LOG_DIR"

    if [[ "$FORCE" == "false" ]]; then

        while true; do
            read -r -n 1 -p "Delete log files? (y/N): " ans2
            echo ""

            if [[ $ans2 =~ ^[Yy]$ ]]; then
                sudo rm -rf "$LOG_DIR"
                echo "Deleted $LOG_DIR"

                break
            elif [[ $ans2 =~ ^[Nn]$ ]]; then
                echo "Keeping logs"
                break
            else
                echo "Invalid choice: $ans2, please use 'y' or 'n'"
            fi
        done

    else
        sudo rm -rf "$LOG_DIR"
        echo "Deleted $LOG_DIR"
    fi
fi

## Prompt to remove zabbix user/group if they exist
echo ""
echo "[ Remove zabbix user/group ]"
echo ""

if id "zabbix" &>/dev/null; then
    echo "Found zabbix user (UID $(id -u zabbix))"

    if [[ "$FORCE" == "false" ]]; then
        while true; do
            read -r -n 1 -p "Delete zabbix user? (y/N): " ans_user
            echo ""

            if [[ $ans_user =~ ^[Yy]$ ]]; then
                ## Stop any processes, remove home dir, then user
                sudo pkill -u zabbix || true
                sudo rm -rf /var/lib/zabbix /home/zabbix || true
                sudo userdel --force zabbix || true
                
                echo "Deleted zabbix user"
                
                break
            elif [[ $ans_user =~ ^[Nn]$ ]]; then
                echo "Keeping zabbix user"
                break
            else
                echo "Please use 'y' or 'n'"
            fi
        done
    else
        ## Stop any processes, remove home dir, then user
        sudo pkill -u zabbix || true
        sudo rm -rf /var/lib/zabbix /home/zabbix || true
        sudo userdel --force zabbix || true
        
        echo "Deleted zabbix user"
    fi
fi

if getent group zabbix &>/dev/null; then
    echo "Found zabbix group (GID $(getent group zabbix | cut -d: -f3))"

    if [[ "$FORCE" == "false" ]]; then
        while true; do
            read -r -n 1 -p "Delete zabbix group? (y/N): " ans_group
            echo ""

            if [[ $ans_group =~ ^[Yy]$ ]]; then
                sudo groupdel zabbix || true
                echo "Deleted zabbix group"
                
                break
            elif [[ $ans_group =~ ^[Nn]$ ]]; then
                echo "Keeping zabbix group"
                break
            else
                echo "Please use 'y' or 'n'"
            fi
        done
    else
        sudo groupdel zabbix || true
        echo "Deleted zabbix group"
    fi
fi

## Clean leftover service files
echo "[ Post-uninstall cleanup ]"
echo ""

echo "Removing systemd service files"
sudo rm -f /etc/systemd/system/zabbix-agent.service || true
sudo rm -f /etc/systemd/system/zabbix-agent2.service || true

sudo systemctl daemon-reload

echo
echo "Zabbix agent uninstall complete"
echo ""
