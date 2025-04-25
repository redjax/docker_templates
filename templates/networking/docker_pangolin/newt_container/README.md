# Pangolin Newt

[Newt](https://github.com/fosrl/newt) is the Pangolin tunnel service that connects your backend servers to your Pangolin instance.

## Setup

Copy and paste the [`compose.yml`](./compose.yml) to your backend server. Create a `.env` file and copy the contents of the [example `.env` file](./.env.example). Set your proxy's URL, and your newt ID/secret, then run `docker compose up -d`.
