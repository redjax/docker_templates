#!/bin/bash

## Generate Concourse CI secrets

function generate_secret () {
    openssl rand -hex 32
}

CONCOURSE_CLIENT_SECRET=$(generate_secret)
CONCOURSE_TSA_SECRET=$(generate_secret)
DB_PASS=$(generate_secret)

echo ""
echo "[ Concourse CI Secrets ]"
echo ""
echo "Instructions:"
echo "  Copy the values below into their corresponding variables in ./.env (copy ./.env.example -> .env if it does not exist)"
echo "-----------------------------------------------------------------------------------------------------------------------"
echo ""
echo "CONCOURSE_CLIENT_SECRET=${CONCOURSE_CLIENT_SECRET}"
echo "CONCOURSE_TSA_CLIENT_SECRET=${CONCOURSE_TSA_SECRET}"
echo "POSTGRES_PASSWORD=${DB_PASS}"
echo ""
