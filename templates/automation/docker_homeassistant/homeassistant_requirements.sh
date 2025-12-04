#!/bin/bash

## https://pimylifeup.com/home-assistant-docker-compose/#setting-up-a-basic-home-assistant-config

if [[ ! -d ./config/homeassistant ]]; then
  echo "Creating HomeAssistant config directory"
  mkdir -pv ./config/homeassistant
fi

if [[ ! -f ./config/homeassistant/configuration.yml ]]; then
  HOST_IP=$(hostname -I | cut -f1 -d' ')

  echo "Creating HomeAssistant config file"
  cat <<EOF >./config/homeassistant/configuration.yml
# Loads default set of integrations. Do not remove.
default_config:

# Load frontend themes from the themes folder
frontend:
  themes: !include_dir_merge_named themes

automation: !include automations.yaml
script: !include scripts.yaml
scene: !include scenes.yaml

panel_iframe:
  configurator:
    title: Configurator
    icon: mdi:wrench
    url: http://${HOST_IP}:3218/
    require_admin: true
  nodered:
    title: Node-Red
    icon: mdi:shuffle-variant
    url: http://${HOST_IP}:1880/
    require_admin: true
EOF
fi
