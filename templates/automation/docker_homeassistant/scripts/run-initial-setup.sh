#!/usr/bin/env bash
set -uo pipefail

##
# Run this script the first time you clone this one a new machine.
# It sets up all the directories and UNIX users the stack expects.
##

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT=$(realpath -m "$THIS_DIR/..")
SCRIPTS_DIR="${PROJECT_ROOT}/scripts"

HOMEASSISTANT_CONFIGURATOR_SETUP_SCRIPT="${SCRIPTS_DIR}/homeassistant_configurator_requirements.sh"
HOMEASSISTANT_SETUP_SCRIPT="${SCRIPTS_DIR}/homeassistant_requirements.sh"
MOSQUITTO_SETUP_SCRIPT="${SCRIPTS_DIR}/mosquitto_requirements.sh"

function main() {
  ## Run HomeAssistant Configurator setup script
  [ -f "${HOMEASSISTANT_CONFIGURATOR_SETUP_SCRIPT}" ] && . "$HOMEASSISTANT_CONFIGURATOR_SETUP_SCRIPT" || {
    echo "[ERROR] Could not find HomeAssistant Configurator script: ${HOMEASSISTANT_CONFIGURATOR_SETUP_SCRIPT}"
    exit 1
  }
  setup_homeassistant_configurator || {
    echo "[ERROR] Failed to do HomeAssistant Configurator setup."
    exit 1
  }

  ## Run HomeAssistant setup script
  [ -f "${HOMEASSISTANT_SETUP_SCRIPT}" ] && . "${HOMEASSISTANT_SETUP_SCRIPT}" || {
    echo "[ERROR] Could not find HomeAssistant script: ${HOMEASSISTANT_SETUP_SCRIPT}"
    exit 1
  }
  setup_homeassistant || {
    echo "[ERROR] Failed to do HomeAssistant setup."
    exit 1
  }

  ## Run Mosquitto setup script
  [ -f "${MOSQUITTO_SETUP_SCRIPT}" ] && . "${MOSQUITTO_SETUP_SCRIPT}" || {
    echo "[ERROR] Could not find Mosquitto script: ${MOSQUITTO_SETUP_SCRIPT}"
    exit 1
  }
  setup_mosquitto || {
    echo "[ERROR] Failed to do Mosquitto setup."
    exit 1
  }

  echo ""
  echo "Setup complete. Run \`docker compose up -d\` to start the HomeAssistant container."
  echo "Run additional containers with \`docker compose -f compose.yml -f overlays/<overlay-name>.yml up -d\`"  
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
