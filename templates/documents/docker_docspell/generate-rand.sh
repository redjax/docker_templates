#!/bin/bash

#
# Generate a random password for the container
#
# Generates 3 secrets for env variables:
#  DOCSPELL_RESTSERVER_SECRET
#  DOCSPELL_RESTSERVER_AUTH_SECRET
#  DOCSPELL_SERVER_INTEGRATION_PASSWORD

password_characters=14
output_file=./secret

restserver_secret=$(openssl rand -base64 32)
restserver_auth_secret=$(openssl rand -base64 32)
server_integration_secret=$(openssl rand -base64 32)

declare -a secrets_array=($restserver_secret $restserver_auth_secret $server_integration_secret)

if [ -f $output_file ]; then
  rm $output_file
fi

echo ""
echo "Generating secrets..."
echo ""

for sec in "${secrets_array[@]}"
do
  echo $sec >> $output_file
done

echo ""
echo "3 secrets will be printed."
echo ""
read -p "Press a key to show secrets..."
clear

echo "Copy each secret into the following variables in .env:"
echo "  DOCSPELL_RESTSERVER_SECRET="
echo "  DOCSPELL_RESTSERVER_AUTH_SECRET="
echo "  DOCSPELL_SERVER_INTEGRATION_PASSWORD="
echo ""
echo "---------"
echo " SECRETS "
echo "---------"

cat $output_file

echo ""
read -p "Press a key once you've copied the secrets..."
echo ""

echo ""
echo "Removing secrets file"
echo ""

rm $output_file
