# Concourse Worker

The [Concourse CI server](../compose.yml) adds a worker, the "default" worker. This compose stack is a standalone worker.

This is not meant to be run on the same server as the Concourse CI server, this is for adding workers to other nodes.

## Setup

During the Concourse server initial setup, you generated SSH keys using [the `generate_ssh_keys.sh` script](../scripts/generate_ssh_keys.sh). This created a [keys/ directory](../keys/), and generated an SSH key that workers should use at `keys/worker/worker_key.pub`.

Copy those keys from the Concourse server and place them in the [`keys/worker/` directory](./keys/worker/).

Set your environment variables in [`.env`](.env.example) (copy `.env.example` -> `.env`):

- `CONCOURSE_WORKER_HEALTHCHECK_URL`: The URL of your Concourse server.
- `CONCOURSE_CLUSTER_NAME`: This value is defined on the server, just make it the same here.
- `CONCOURSE_WORKER_TSA_HOST`: Set this to the server's IP (if on the same network) or FQDN/hostname.
