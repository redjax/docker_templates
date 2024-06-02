# Mayan Document Management System in docker-compose

## First setup

* Run the `initial-setup.sh` script
  * This will download the docker-compose.yml, .env, and env_file files from Mayan's gitlab
  * If those files already exist (they should), the script skips them and uses the existing file
  * The script also creates the necessary directories if they don't exist
* Run the `change-admin-password.sh` script
  * This will run the container and prompt you for the default web admin account login.
  * If no admin account exists, you can run `docker exec -it $MAYAN_APP_CONTAINER_NAME /bin/bash` and in the container, navigate to /opt/mayan-edms/bin
    * To create the admin account, run ./mayan-edms.py createsuperuser

## Backing up container database & doc files
* Run the `backup-mayan-db.sh` and `backup-mayan-documents.sh` scripts to create backups of the database and documents volume.
* Restore functionality is still a WIP, you'll have to do it manually for now.