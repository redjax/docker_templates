#!/bin/bash

#
# Initial setup script. Only run after cloning onto new machines!
#
example_app_secrets_file="./src/config/confs/example_app_secrets.json"
app_secrets_file="./src/config/confs/app_secrets.json"

example_env_file="./.env.example"
env_file="./.env"

function copy_example_file () {
    # Copies an example_*.* file to the "real" version
    if [[ ! -f $1 ]]; then
      cp $1 $2
    else
      echo "File $1 already exists. Skipping"
    fi
}

main () {
    echo ""
    echo "Creating app_secrets.json. Don't forget to set it up!"
    copy_example_file $example_app_secrets_file $app_secrets_file

    echo ""
    echo "Creating .env. Don't forget to fill in required variables!"
    copy_example_file $example_env_file $env_file
}

main
