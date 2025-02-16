#!/bin/bash

if ! command -v docker compose --help > /dev/null 2>&1; then

    echo "docker compose is not installed"
    exit 1
fi

function generate_certs() {
    echo "Generating SSL certificates."
    docker compose -f generate-certs.yml run --rm generator
}

function main() {
    generate_certs
}

main
