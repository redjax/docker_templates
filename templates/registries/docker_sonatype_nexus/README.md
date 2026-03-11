# Sonatype Nexus

[Sonatype Nexus](https://github.com/sonatype/docker-nexus3) is a self-hostable container and package registry

## Setup

- Copy the [example `.env` file](./.env.example) to `.env`
  - (optional) edit the `.env` file, i.e. to change the HTTP port
- Bring the stack up with `docker compose up -d`
- Retrieve the default admin password with `docker compose exec -it nexus cat /nexus-data/admin.password`
  - You can also use the [`get_admin_pw.sh`](./get_admin_pw.sh) script to retrieve the password
- Navigate to your Nexus registry, `http://192.168.1.xxx:8081`
  - If you set a different value for `NEXUS_HTTP_PORT`, use that port instead of `:8081`
