#!/bin/bash

mongo_port="27017"
mongo_data_dir="mongodb_data"
mongo_container_name="mongodb-test"
mongo_image="mongo:4.4"

mongo_root_user="mongoadmin"
mongo_root_pw="mongo"

echo "[DEBUG] mongo_port: $mongo_port"
echo "[DEBUG] mongo_data_dir: $mongo_data_dir"
echo "[DEBUG] mongo_container_name: $mongo_container_name"
echo "[DEBUG] mongo_image: $mongo_image"
echo "[DEBUG] mongo_root_user: $mongo_root_user"
echo "[DEBUG] mongo_root_pw: $mongo_root_pw"

echo "Creating volume $mongo_data_dir"
docker volume create $mongo_data_dir

echo "[DEBUG] launch string:"
echo "  docker run -d --name $mongo_container_name -p $mongo_port:27017 -v $mongo_data_dir:/data/db -e MONGO_INITDB_ROOT_USERNAME='$mongo_root_user' -e MONGO_INITDB_ROOT_PASSWORD='$mongo_root_pw' $mongo_image"

docker run -d --name $mongo_container_name \
    -p $mongo_port:27017 \
    -v $mongo_data_dir:/data/db \
    -e MONGO_INITDB_ROOT_USERNAME="$mongo_root_user" \
    -e MONGO_INITDB_ROOT_PASSWORD="$mongo_root_pw" \
    $mongo_image