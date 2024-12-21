#!/bin/bash

if ! command -v docker compose version &> /dev/null; then
    echo "Docker Compose is not installed. Please install Docker Compose and try again."
    exit 1
fi

echo ""
read -p "Name of the ollama model to install: " OLLAMA_MODEL_NAME

echo ""
echo "Installing ollama model $OLLAMA_MODEL_NAME in open-webui container."
docker compose exec -it open-webui /bin/bash -c "ollama run ${OLLAMA_MODEL_NAME}"
if [[ ! $? -eq 0 ]]; then
    echo "Failed to install ollama model $OLLAMA_MODEL_NAME in open-webui container."
    exit 1
else
    echo "[SUCCESS] Successfully installed ollama model $OLLAMA_MODEL_NAME in open-webui container."
fi
