# TinyTinyRSS

TinyTiny RSS reader.

## Setup

- Copy [`.env.example`](./.env.example) -> `.env`
  - Edit the following env vars:
      - `ADMIN_USER_PASS=<your-secure-admin-password>`
      - (Optional, if you want a non-admin user)
        - `AUTO_CREATE_USER=<name-of-user>`
        - `AUTO_CREATE_USER_PASS=<your-user-password>`
        - `AUTO_CREATE_USER_ACCESSLEVEL=0`
      - (Optional, recommended for security)
        - `TTRSS_DB_USER=<your-db-user>`
        - `TTRSS_DB_NAME=<name-of-ttrss-database>`
        - `TTRSS_DB_PASS=<database-password>`
      - `TTRSS_SELF_URL_PATH=http(s)://your-fqdn-or-ip/tt-rss`
        - If you don't want to have to type `/tt-rss`, uncomment the `APP_WEB_ROOT` and `APP_BASE` vars
      - `HTTP_PORT=8280` (remove the `127.0.0.1` if accessing outside your localhost)
