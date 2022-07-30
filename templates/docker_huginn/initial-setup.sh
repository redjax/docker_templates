#!/bin/bash

container_name="huginn"
huginn_volume="huginn_data"
env_file=".env.huginn"
example_env=".env.huginn.example"

echo "Creating Huginn data volume: $huginn_volume"

docker volume create $huginn_volume

if [[ ! -f $env_file ]]; then
    echo "Creating .env.huginn file"

    cp $example_env $env_file
fi
