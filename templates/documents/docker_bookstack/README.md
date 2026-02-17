# Bookstack

[Bookstack](https://www.bookstackapp.com) is a simple & free wiki software.

## Setup

- Copy the [example `.env`](./.env.example) to `.env`
- Generate a database root password with `./generate_db_root_pass.sh`
  - Copy the generated password into `.env`'s `DB_ROOT_PASSWORD`
- Generate the app secret with `./generate_app_key.sh`
  - Copy the generated secret into `.env`'s `BOOKSTACK_APP_KEY`
- Run `docker compose up -d`

Your Bookstack webUI will be available at the address you set in `BOOKSTACK_APP_URL`. The default admin login is:

|          |                   |
| -------- | ----------------- |
| Username | `admin@admin.com` |
| Password | `password`        |
