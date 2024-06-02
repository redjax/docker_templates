#!/bin/bash

function MAYAN_COMPOSE () {

  docker-compose --file docker-compose.yml --project-name mayan $1

}

case $1 in
  "-u" | "up" | "start")
    MAYAN_COMPOSE "up -d"
  ;;
  "-d" | "down" | "stop")
    MAYAN_COMPOSE "down"
  ;;
  "-r" | "restart" | "--restart")
    MAYAN_COMPOSE "down"
    MAYAN_COMPOSE "up -d"
  ;;
  "-rc" | "recreate" | "--recreate")
    MAYAN_COMPOSE "down"
    MAYAN_COMPOSE "up -d --force-recreate"
  ;;
  *)
    echo ""
    echo "Error: invalid/no flag."
    echo ""
    echo "Valid options:"
    echo "    -u/up/start"
    echo "    -d/down/stop"
    echo ""
  ;;
esac
