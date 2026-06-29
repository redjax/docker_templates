# Rundeck

Automation platform for Ansible, Terraform/OpenTofu, Bash, Powershell, & more.

The default login is `admin:admin`.

## Setup

Note that by default, all data is stored in Docker volumes. If you want this data mounted on your host, update the `RUNDECK_DATA_DIR`, `RUNDECK_LOGS_DIR`, and `MARIADB_DATA_DIR` variables with paths on your host.

Setup steps:

- Copy [`example.realm.properties`](./example.realm.properties) to `realm.properties`
  - In this file you can add more users, and change the default admin password.
    - Look for the line `admin:admin,user,admin,architect,deploy,build`
    - The syntax is `<username>:<password>`, so to update the password, change `:admin` to a different password
  - **!! You should bcrypt encrypt your admin password !!**
    - Storing passwords in plaintext is not safe.
    - The `rundeck` Docker image provides a utility for encrypting your password:
      - `docker exec -it rundeck java -jar /home/rundeck/rundeck.war --encryptpwd Jetty`
      - Running this command will prompt you for an optional username and a password, and will output the password as a bcrypt, obfuscate, md5, and crypt string.
- Copy [`.env.example`](./.env.example) to `.env`
  - Set `RUNDECK_GRAILS_URL` to your server's IP or FQDN
    - Examples:
      - `http://192.168.1.50:4440` (change the port if you set a different `RUNDECK_PORT`)
      - `https://rundeck.example.com` (if you're behind a reverse proxy, you must set `RUNDECK_SERVER_FORWARDED=true`)
  - Update any passwords in this file (using the docker command above)
- Generate SSH keys with [`gen_ssh_keys.sh`](./scripts/gen_ssh_keys.sh) on Linux, or [`gen_ssh_keys.ps1`](./scripts/gen_ssh_keys.ps1) on Windows
  - Set the following variables in your `.env` file:
    - `RUNDECK_SSH_PRIVATE_KEY=./ssh/rundeck_id_rsa`
    - `RUNDECK_SSH_PUBLIC_KEY=./ssh/rundeck_id_rsa.pub`
    - `RUNDECK_SSH_KNOWN_HOSTS=./ssh/known_hosts`
- Run with `docker compose up -d`
  - If you are using a firewall, you must allow port `4440` (or whatever you set in `RUNDECK_PORT`)

## Links

- [Rundeck Docker](https://github.com/jjethwa/rundeck/tree/master)
- [Rundeck Github](https://github.com/rundeck/docker-zoo)
  - [Basic Rundeck template](https://github.com/rundeck/docker-zoo/blob/master/basic/docker-compose.yml)
  - [Rundeck NGINX config example](https://github.com/jjethwa/rundeck/blob/master/nginx/nginx.conf)
  - [Rundeck compose.yml example](https://github.com/jjethwa/rundeck/blob/master/docker-compose.yml)
- [Rundeck Zoo: example configurations](https://github.com/rundeck/docker-zoo/tree/master)
