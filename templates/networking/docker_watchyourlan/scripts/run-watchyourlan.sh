#!/usr/bin/env bash
set -euo pipefail

function pull_container() {
  echo "Pulling container: aceberg/watchyourlan:v2"
  docker pull aceberg/watchyourlan:v2
}

function run_container() {
  echo "Running container: aceberg/watchyourlan:v2"
  docker -it --rm run --name watchyourlan \
    -e "IFACES=enp2s0" \
    -e "TZ=America/New_York" \
    --network="host" \
    -v watchyourlan_data:/data/WatchYourLan \
    aceberg/watchyourlan:v2
}

function restart_container() {
  echo "Restarting container: watchyourlan"
  docker restart watchyourlan
}

function main() {
  pull_container
  run_container

  if [[ ! $? -eq 0 ]]; then
    echo "Detected non-zero exit code: $?. Attempting to restart watchyourlan container."
    restart_container
  fi
}

main
