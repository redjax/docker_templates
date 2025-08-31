#!/bin/bash

if ! command -v docker &> /dev/null; then
    echo "[ERROR] Docker is not installed. Install Docker and try again."
    exit 1
fi

echo "Registering Gitlab runner"
echo ""

docker run --rm -it \
  -v $(pwd)/gitlab-runner/config:/etc/gitlab-runner \
  gitlab/gitlab-runner:latest register

if [[ $? -ne 0 ]]; then
    echo "[ERROR] Failed to register Gitlab runner"
    exit 1
else
    echo "Gitlab runner registered successfully. Restart the Compose stack to bring the embedded runner up."
    exit 0
fi
