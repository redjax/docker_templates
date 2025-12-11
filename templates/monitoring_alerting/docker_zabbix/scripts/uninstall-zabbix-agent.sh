#!/usr/bin/env bash
set -uo pipefail

echo ""
echo "[ Zabbix Agent Uninstall ]"
echo " ------------------------ "
echo ""

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
stop_service() {
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
    
    while true; do
        read -n 1 -r -p "Delete this directory? (y/N): " ans
        echo ""

        if [[ $ans =~ ^[Yy]$ ]]; then
            sudo rm -rf "$CONFIG_DIR"
            echo "Deleted $CONFIG_DIR"
        elif [[ $ans =~ ^[Nn]$ ]]; then
            echo "Keeping dir: $CONFIG_DIR"
            break
        else
            echo "Invalid choice: $ans, please use 'y' or 'n'"
        fi
    done
fi

if [[ -d "$LOG_DIR" ]]; then
    echo "Found logs at $LOG_DIR"

    while true; do
        read -r -n 1 -p "Delete log files? (y/N): " ans2
        echo ""

        if [[ $ans2 =~ ^[Yy]$ ]]; then
            sudo rm -rf "$LOG_DIR"
            echo "Deleted $LOG_DIR"
        elif [[ $ans2 =~ ^[Yy]$ ]]; then
            echo "Keeping logs"
            break
        else
            echo "Invalid choice: $ans2, please use 'y' or 'n'"
        fi
    done
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
