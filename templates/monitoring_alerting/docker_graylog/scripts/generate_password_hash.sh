#!/bin/bash

read -sp "Graylog root password to hash: " PASSWORD

PASSWORD_HASH=$(echo -n "${PASSWORD}" | shasum -a 256)

echo "Password hash:"
echo "${PASSWORD_HASH::-3}"
