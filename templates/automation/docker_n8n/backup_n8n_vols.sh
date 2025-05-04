#!/bin/bash

# Path to directory this script exists in
this_dir=$HOME/docker/docker_templates/templates/docker_n8n

# Directory to store backup archive
host_backup_dir=$this_dir/backup/volume_data

# Name of volume with data to back up
data_volume_name="n8n_conf"

# Name of container with data to back up
source_container_name="n8n"

# Path in container to backup data
source_container_data_path="/home/node/.n8n"

if [[ ! -d $host_backup_dir ]]; then
    mkdir -pv $host_backup_dir
fi

echo "Backing up $data_volume_name"

docker run --rm \
    --volumes-from $source_container_name \
    -v $host_backup_dir:/backup \
    ubuntu \
    tar cvf /backup/n8n_conf_backup.tar /home/node/.n8n