#!/bin/bash

## https://pimylifeup.com/home-assistant-docker-compose/#setting-up-a-basic-home-assistant-config

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT=$(realpath -m "$THIS_DIR/..")

function setup_homeassistant() {
  if [[ ! -d $PROJECT_ROOT/config/homeassistant ]]; then
    echo "Creating HomeAssistant config directory"
    mkdir -pv $PROJECT_ROOT/config/homeassistant
  fi

  if [[ ! -f $PROJECT_ROOT/config/homeassistant/configuration.yml ]]; then
    HOST_IP=$(hostname -I | cut -f1 -d' ')

    echo "Creating HomeAssistant config file"
    cat <<EOF >$PROJECT_ROOT/config/homeassistant/configuration.yml
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
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_homeassistant
fi