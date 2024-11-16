#!/bin/bash

## Get user password before running container.
#  Hide password input with -s
read -s -p "Password to encrypt: " USER_PASSWORD

echo "Hashing password with wg-easy container"
docker run -it ghcr.io/wg-easy/wg-easy wgpw "${USER_PASSWORD}"

echo "Paste the password above into your .env file's 'WG_EASY_ADMIN_PASSWORD_HASH' variable. Make sure to change any '$' symbols to '\$\$'!"