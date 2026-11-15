# Joplin

[Joplin](https://joplinapp.org) is a Markdown note-taking app.

## Usage

- Copy `.env.example` to `.env`
  - Make sure the `JOPLIN_BASE_URL` matches the IP or FQDN you use to access the server
- Run the stack with `docker compose -f compose.yml -f overlays/postgres.yml`
  - If you want to use an external database, configure it in `.env` and just run `docker compose up -d`
- Access the webui at `http(s)://your-ip-or-fqdn:22300`
  - Initial login information:
    - Email: `admin@localhost`
    - Password: `admin`

