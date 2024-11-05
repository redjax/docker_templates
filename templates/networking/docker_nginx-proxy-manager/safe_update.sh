#!/bin/bash

DATA_DIR="data"
DATA_BAK_DIR="data.bak"

function check_path_exists() {
  if [[ -d "${1}" ]]; then
    # echo "Path '${1}' exists"
    return 0
  else
    # echo "Path '${1}' does not exist"
    return 1
  fi
}

function main() {
  ## 0=exists, 1=not exists
  BAK_DIR_EXISTS=$(check_path_exists "${DATA_BAK_DIR}")

  if [[ $BAK_DIR_EXISTS -eq 0 ]]; then
    echo "$DATA_BAK_DIR exists"
  else
    echo "$DATA_BAK_DIR does not exist"
  fi
}

main
