# Feedbin

[Feedbin](https://github.com/feedbin/feedbin) is a self-hostable RSS feed reader.

> [!WARNING]
> This template does not work in its current state. If I ever get it working I'll remove this message.

## Usage

- Copy [example `.env` file](./.env.example) to `.env`
- Generate secrets by running the `generate_*.sh` scripts in [`./scripts`](./scripts/)
  - Add the values to your `.env` file
- Create the database:
  - `docker compose run --rm freedbin-app rake db:setup`
  - `docker compose run --rm freedbin-app rake db:migrate`
- Bring the stack up with `docker compose up -d`
