# LinuxServer MySQL Workbench

https://hub.docker.com/r/linuxserver/mysql-workbench

## Requirements

- A Docker network named `mysql_workbench-net`
  - `$ docker network create mysql_workbench-net`
  - Add this to the `networks:` section of a `docker-compose.yml` file, then add the `mysql_workbench-net` to any `mariadb`/`mysql` containers you want to interact with using the workbench:

```
## docker-compose.yml

networks:
  mysql_workbench-net:
    external: true

services:
  
  ...

  mariadb:
    container_name: mariadb
    networks:
      - mysql_workbench-net

...

```
