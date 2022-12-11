# docker_nginx-proxy-manager

Template for an nginx-proxy-manager instance.

## Instructions:

* Copy `.env.example` to `.env`
* Edit `.env`
  * Edit variables like `NPM_DB_PASSWORD` and `NPM_DB_MYSQL_PASSWORD`
* Copy `config.json.example` to `config.json`
* Edit `config.json`
  * Enter your container's host, name of the database, MySQL user, and the database password

## Logging in for the first time

Default admin login is:
```
USER: admin@example.com
PASS: changeme
```
