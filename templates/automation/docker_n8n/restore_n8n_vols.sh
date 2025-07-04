#!/bin/bash

# Path to directory this script exists in
this_dir=$HOME/docker/docker_templates/templates/docker_n8n

# Directory to store backup archive
host_backup_dir=$this_dir/backup/volume_data

# Name of volume to restore data to
data_volume_name="n8n_conf"

# Name of container with data to back up
target_container_name="n8n"

# Path in container to backup data
target_container_data_path="/home/node/.n8n"

echo "Restoring data to $data_volume_name"

docker run --rm \
    --volumes-from $target_container_name \
    -v $host_backup_dir:/restore \
    ubuntu \
    bash -c "cd $target_container_data_path && \
        tar xvf /restore/n8n_conf_backup.tar --strip 1"