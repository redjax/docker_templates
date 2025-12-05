#!/bin/bash

## https://pimylifeup.com/home-assistant-docker-compose/#configuring-hass-configurator

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT=$(realpath -m "$THIS_DIR/../../../")

if [[ ! -d $PROJECT_ROOT/config/homeassistant-configurator ]]; then
    echo "Creating HomeAssistant Configurator config dir"
fi

if [[ ! -f $PROJECT_ROOT/config/homeassistant-configurator/settings.conf ]]; then
    echo "Creating HomeAssistant Configurator config file"
    cat <<EOF >$PROJECT_ROOT/config/homeassistant-configurator/homeassistant-configurator.conf
{
    "BASEPATH": "../hass-config"
}
EOF

fi
