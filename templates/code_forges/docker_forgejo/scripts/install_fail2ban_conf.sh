#!/bin/bash

FAIL2BAN_CONF="./fail2ban/ssh-multiport.conf"
DEST_CONF="/etc/fail2ban/jail.d/ssh-multiport.conf"
HARDCODED_CONF="[sshd]
enabled = true
port = 22,255138
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 600
findtime = 600
"

## Check if host config exists
if [[ -f "$DEST_CONF" ]]; then
    echo "Fail2Ban config file already exists at: $DEST_CONF"
    echo ""
    read -p "Do you want to overwrite it? (y/n): " overwrite_answer

    case $overwrite_answer in
        [Yy]* )
            ;;
        * )
            echo "Installation cancelled by user."
            exit 0
            ;;
    esac
fi

## Check if the config file exists
if [[ -f "$FAIL2BAN_CONF" ]]; then
    echo "Found local Fail2Ban config file: $FAIL2BAN_CONF. Copying to: $DEST_CONF"

    if sudo cp "$FAIL2BAN_CONF" "$DEST_CONF"; then
        echo "Successfully copied Fail2Ban config to $DEST_CONF"
    else
        echo "Failed to copy Fail2Ban config file."
        exit 1
    fi
else
    echo "Fail2Ban config file not found at: $FAIL2BAN_CONF"
    echo
    echo "Here is the default Fail2Ban ssh-multiport config:"
    echo "----------------------------------------"
    echo "$HARDCODED_CONF"
    echo "----------------------------------------"
    echo ""
    
    read -rp "Do you want to install this config to $DEST_CONF? (y/n): " answer

    case $answer in
        [Yy]* )
            echo "$HARDCODED_CONF" | sudo tee "$DEST_CONF" > /dev/null
            if [[ $? -eq 0 ]]; then
                echo "Config installed successfully."
            else
                echo "Failed to install the config."
                exit 1
            fi
            ;;
        * )
            echo "Installation aborted by user."
            exit 0
            ;;
    esac
fi

read -p "Reload Fail2Ban? (y/n): " restart_answer

case $restart_answer in
    [Yy]* )
        sudo systemctl reload fail2ban
        ;;
    * )
        echo "Fail2Ban was not restarted after installing the SSHD config. Run the following command to restart Fail2Ban:"
        echo " sudo systemctl reload fail2ban"
        ;;
esac
