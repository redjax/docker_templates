# Beszel Agent

## Usage

- Copy [`.env.example`](./.env.example) -> `.env`
- In the Beszel webUI, click 'Add System'
- Edit the `.env` file
  - Paste the key into `AGENT_SSH_KEY`
  - Paste the token into `AGENT_API_TOKEN`
  - Set your server URL in `BESZEL_SERVER_URL`
- Run the server with `docker compose up -d`

## Agent configuration

After starting the server & creating an admin account, log into the webUI and click the `+Add System` button. This will show you a `compose.yml` you can copy and paste, or you can use the [`compose.yml` file](./compose.yml) here.

Either way, copy the value of "Public Key" and "Token" from the "Add System" menu in Beszel and follow the instructions below.

- Copy the [example `.env`](./agent/.env.example) to a `.env` file & edit the values.
- (Optional) If you want to monitor additional disks, copy the [example `disks.yml`](./agent/overlays/example.disks.yml) to `disks.yml`.
  - Edit the `volumes` section, following the pattern to mount a drive from your machine into the monitoring agent container in read-only mode.
  - Run the stack with `docker compose -f compose.yml -f overlays/disks.yml up -d`.
- If you are not mounting additional disks, run the stack with `docker compose up -d`.
