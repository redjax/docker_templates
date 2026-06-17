#!/bin/bash

declare -a DOCKER_FILES=( "docker-compose.yml" ".env" "docker-compose.env" )

function COPY_EXAMPLE_FILE () {

  if [[ ! -f $1 ]]; then
    echo ""
    echo "Copying "$1.example" to "$1
    echo ""
    mv $1.example $1
  elif [[ -f $1 ]]; then
    echo ""
    echo $1" exists. Skipping."
    echo ""
  fi

}

function GENERATE_SECRET_KEY () {

  if [[ ! -f secret_key ]]; then
    echo ""
    echo "Generating secret key."
    echo "Add the secret to the docker-compose.env file"
    echo ""

    openssl rand -base64 64 >> secret_key
  elif [[ -f secret_key ]]; then
    echo ""
    echo "Secret key file exists."
    echo "Open the file and copy the key (getting rid of the newline) into docker-compose.env"
    echo ""
  else
    echo ""
    echo "Unknown error"
    echo ""
  fi

}

for FILE in "${DOCKER_FILES[@]}"
do
  COPY_EXAMPLE_FILE $FILE
done

echo ""
echo "Pausing. Go edit the docker-compose.env, docker-compose.yml, and .env files before continuing."
echo ""
echo "Secret key will be generated in the next step."
echo ""
read -p "Press a key to continue when ready: "
echo ""

GENERATE_SECRET_KEY

echo "Secret key generated. Printing below."
echo "Copy and paste the secret key into the PAPERLESS_SECRET_KEY"
echo "    variable inside docker-compose.env before continuing."
echo ""
echo "Secret key (make sure to remove newlines in docker-compose.env):"
echo ""
cat secret_key

echo ""
read -p "Press a key to continue when ready: "

echo ""
echo "Running docker-compose stack"
echo ""

docker-compose pull
docker-compose up -d

echo ""
echo "Running initial admin setup."
echo ""

docker-compose run --rm webserver createsuperuser

echo ""
echo "Initial setup complete."
echo ""

exit