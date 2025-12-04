#!/bin/bash

## https://pimylifeup.com/home-assistant-docker-compose/#configuring-hass-configurator

if [[ ! -d ./config/homeassistant-configurator ]]; then
    echo "Creating HomeAssistant Configurator config dir"
fi

if [[ ! -f ./config/homeassistant-configurator/settings.conf ]]; then
    echo "Creating HomeAssistant Configurator config file"
    cat <<EOF >./config/homeassistant-configurator/homeassistant-configurator.conf
{
    "BASEPATH": "../hass-config"
}
EOF

fi
