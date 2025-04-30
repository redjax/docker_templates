# Linkwarden

Bookmarks manager

## Setup

- Copy `.env.example` -> `.env`
- Edit the `.env`
  - Set a value for `POSTGRES_PASSWORD`
  - Set a value for `NEXTAUTH_SECRET`
    - This should be a strong password phrase (3+ words, mixed capitalization, symbols, numbers)
    - You can generate a secret with `openssl rand -hex 64`
  - If you are hosting Linkwarden behind a domain, update `NEXTAUTH_URL`
- Run `docker compose up -d`
