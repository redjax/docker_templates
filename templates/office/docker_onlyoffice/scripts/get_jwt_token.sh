#!/bin/bash

docker exec 30f6b6b4b0ac /var/www/onlyoffice/documentserver/npm/json -f /etc/onlyoffice/documentserver/local.json 'services.CoAuthoring.secret.session.string' >> onlyoffice_jwt.token
if [[ $? -ne 0 ]]; then
    echo "Failed to get JWT token"
    exit 1
else
    echo "JWT token saved to onlyoffice_jwt.token"
fi