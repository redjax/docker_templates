#!/bin/bash

# Name of container containing volume(s) to back up
CONTAINER_NAME=${1:-portainer}
THIS_DIR=${PWD}
BACKUP_DIR=$THIS_DIR"/backup"
# Directory to back up in container
CONTAINER_BACKUP_DIR=${2:-/data}
# Container image to use as temporary backup mount container
BACKUP_IMAGE=${3:-busybox}
BACKUP_METHOD=${4:-tar}
DATA_VOLUME_NAME=${5:-portainer-data}

if [[ ! -d $BACKUP_DIR ]]; then
  echo ""
  echo $BACKUP_DIR" does not exist. Creating."
  echo ""

  mkdir -pv $BACKUP_DIR
fi

function RUN_BACKUP () {

  sudo docker run --rm --volumes-from $1 -v $BACKUP_DIR:/backup $BACKUP_IMAGE $2 /backup/backup.tar $CONTAINER_BACKUP_DIR

}

function RESTORE_BACKUP () {

  echo ""
  echo "The restore function is experimental until this comment is removed."
  echo ""
  read -p "Do you want to continue? Y/N: " choice

  case $choice in
    [yY] | [YyEeSs])
      echo ""
      echo "Test print: "
      echo "sudo docker create -v $CONTAINER_BACKUP_DIR --name $DATA_VOLUME_NAME"2" $BACKUP_IMAGE true"
      echo ""
      echo "Test print: "
      echo "sudo docker run --rm --volumes-from $DATA_VOLUME_NAME"2" -v $BACKUP_DIR:/backup $BACKUP_IMAGE tar xvf /backup/backup.tar"
      echo ""

      echo ""
      echo "Compare to original container: "
      echo ""
      echo "Test print: "
      echo "sudo docker run --rm --volumes-from $CONTAINER_NAME -v $BACKUP_DIR:/backup $BACKUP_IMAGE ls /data"
    ;;
    [nN] | [NnOo])
      echo ""
      echo "Ok, nevermind."
      echo ""
    ;;
  esac

}

# Run a temporary container, mount volume to back up, create backup file
case $1 in
  "-b" | "--backup")
  case $BACKUP_METHOD in
    "tar")
      echo ""
      echo "Running "$BACKUP_METHOD" backup using image "$BACKUP_IMAGE
      echo ""

      RUN_BACKUP $CONTAINER_NAME "tar cvf"
    ;;
  esac
  ;;
  "-r" | "--restore")
  ;;
esac
