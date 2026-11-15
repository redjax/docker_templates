#!/bin/bash

if ! command -v docker compose version &>/dev/null; then
  echo "Docker Compose is not installed. Please install Docker Compose and try again."
  exit 1
fi

echo ""
read -r -p "Name of the ollama model to install: " OLLAMA_MODEL_NAME
echo

echo ""
read -r -p "Compose file to use: " COMPOSE_FILE
echo

if [[ $COMPOSE_FILE -eq "" ]]; then
  echo "No compose file detected, defaulting to AllInOne container stack."
  COMPOSE_FILE="aio-nvidia.compose.yml"
fi

echo ""
echo "Installing ollama model $OLLAMA_MODEL_NAME in open-webui container."
if ! docker compose -f "$COMPOSE_FILE" exec -it open-webui /bin/bash -c "ollama run ${OLLAMA_MODEL_NAME}" 2>&1; then
  echo "Failed to install ollama model $OLLAMA_MODEL_NAME in open-webui container."
  exit 1
else
  echo "[SUCCESS] Successfully installed ollama model $OLLAMA_MODEL_NAME in open-webui container."
fi
