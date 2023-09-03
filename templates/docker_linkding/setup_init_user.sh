#!/bin/bash

read -p "Linkding user name: " LINKDING_USER
read -p "Linkding user email: " LINKDING_EMAIL

echo "Creating user [$LINKDING_USER:$LINKDING_EMAIL]"

docker-compose exec linkding python manage.py createsuperuser --username=$LINKDING_USER --email=$LINKDING_EMAIL

if [[ $? == 0 ]]; then
    echo "Success."
    exit
else
    echo "Failure."
fi

exit $?
