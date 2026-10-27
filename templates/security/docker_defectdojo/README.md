# Defect Dojo

[DefectDojo](https://github.com/DefectDojo/django-DefectDojo) is a Django DevSecOps, APSM (application security posture management), and vulnerability management tool.

## Setup

- Copy the [example `.env` file](./.env.example) to `.env`
- Run the [`generate-secrets.sh` script](./scripts/generate-secrets.sh)
  - Paste the values from the script into the appropriate vars in the `.env` file
- Run the `docker compose up` command with optional [layers](./overlays/)
  - If you are running everything locally, the command is:

    ```shell
    docker compose -f compose.yml \
      -f overlays/postgres.yml \
      -f overlays/valkey.yml \
      up -d
    ```
  - If you are connecting to a remote Postgres and/or Redis/Valkey, simply omit them from the `docker compose -f ...` command.
  - For example, if you are connecting to an external Postgres database, set the connection details in the `.env` file, then use:

    ```shell
    docker compose -f compose.yml \
      -f overlays/valkey.yml \
      up -d
    ```
- Once the stack is running, retrieve the admin password by running [`./scripts/get-admin-password.sh`](./scripts/get-admin-password.sh)
- Navigate to the DefectDojo webUI at `http://<ip-or-fqdn>:8080` and login with the username `admin` and the password you retrieved in the last step
