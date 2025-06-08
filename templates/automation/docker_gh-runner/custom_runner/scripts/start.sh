#!/bin/bash
set -e

# Required environment variables: GH_RUNNER_URL, GH_RUNNER_TOKEN
if [ -z "$GH_RUNNER_URL" ] || [ -z "$GH_RUNNER_TOKEN" ]; then
  echo "GH_RUNNER_URL and GH_RUNNER_TOKEN environment variables must be set."
  exit 1
fi

cd /home/docker/actions-runner

# Register the runner (only if not already configured)
if [ ! -f .runner ]; then
  ./config.sh --unattended --url ${GH_RUNNER_URL} --token ${GH_RUNNER_TOKEN} --name $(hostname)-${RANDOM}
fi

cleanup() {
  echo "Removing runner..."
  ./config.sh remove --unattended --token ${GH_RUNNER_TOKEN}
}
trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

# Start the runner
./run.sh
