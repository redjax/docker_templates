#!/bin/bash

container_name="mongodb-test"

echo "Starting log flow for $container_name"
docker compose logs -f $container_name
