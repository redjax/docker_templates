# Reactive Resume

[Reactive Resume](https://github.com/amruthpillai/reactive-resume) is a self-hostable resume builder.

## Instructions

- Copy `.env.example` to `.env`
- Run `./generate_secrets.sh`
- Open the `secrets_DELETE_ME` file the script generates and copy the secrets into their respective values in `.env`
- Run `docker compose up -d`
- Navigate to `http://your-ip-or-fqdn`
  - If you changed `CADDY_HTTP_PORT`, i.e. to `8080`, add it to the end of the url like `http://your-ip-or-fqdn:8080`
