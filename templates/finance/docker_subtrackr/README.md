# Subtrackr

[Subtrackr](https://github.com/bscott/subtrackr) is a self hosted subscription tracker.

## Setup

- Copy [example `.env`](./.env.example) to `.env` and edit it.
  - If you want to change the port the app runs on, set `SUBTRACKR_PORT`.
  - If you want to mount the app's data dir on the host, set `SUBTRACKR_DATA_DIR` to a host path, i.e. `./data`.
  - If you have a [fixer.io](https://fixer.io) API key for currency conversions, paste it in `FIXER_API_KEY`.
- Run the container with `docker compose up -d`.
- Access the webUI at `http://<your-ip-or-fqdn>:8080` (or whatever port you set).
  - The app is ready to use, but you can still configure authentication.
  - You must configure email settings, then scroll down and enable `Require Login`.
  - For example, to configure a Gmail account for SMTP:
    - Server address: smtp.gmail.com
    - Username: Your Gmail address (for example, `example@gmail.com`)
    - SMTP password: Your Gmail password (or an [app password](https://support.google.com/accounts/answer/185833))
    - Port (TLS): 587
    - Port (SSL): 465
    - TLS/SSL required: Yes
