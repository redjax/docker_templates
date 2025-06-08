# Pangolin Newt

[Newt](https://github.com/fosrl/newt) is the Pangolin tunnel service that connects your backend servers to your Pangolin instance.

## Setup

Copy and paste the [`compose.yml`](./compose.yml) to your backend server. Create a `.env` file and copy the contents of the [example `.env` file](./.env.example). Set your proxy's URL, and your newt ID/secret, then run `docker compose up -d`.

After running the Newt container, you can use your server's local IP (your LAN IP for the machine) in Pangolin's webUI to create a "resource." For example, if you have a service running on your local machine on port `:8084`, you can create a service and use `192.168.1.xxx:8084` and Pangolin's server will be able to find it, even if the Pangolin server and local backend are in different countries!
