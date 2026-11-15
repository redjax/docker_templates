# HappyDomain

[HappyDomain](https://www.happydomain.org/en/) is a toolbox for managing domains you own.

> [!NOTE]
> The `compose.yml` is for smaller scale/personal deployments. See the [`largescale_deployment/` directory](./largescale_deployment/) for a "production ready" version that deploys the individual checker containers.
>
> This personal-scale version still runs the checkers, but bundled in a single container image. This is plenty for most users.

## Setup

- Copy the [example `.env`](.env.example) to `.env`
- If you are testing the container, set `HAPPYDOMAIN_NO_AUTH=1` to disable authentication
- Bring the stack up with `docker compose up -d`
- Navigate to `http://your-ip-or-address:8081`
  - If you changed `HAPPYDOMAIN_HTTP_PORT`, use the port value you set in that env var instead of `:8081`

## Troubleshooting

### Pool overlaps with other one on this address

If you see an error like this when running the HappyDomain container:

```plaintext
✘ Network happydomain_default Error Error response from daemon: invalid pool request: Pool overlaps with other one on this address space                                                         0.0s
failed to create network happydomain_default: Error response from daemon: invalid pool request: Pool overlaps with other one on this address space
```

Check the value of `HAPPYDOMAIN_SUBNET`. This error means the default subnet `172.28.0.0/24` is already in use by another Docker network. There are 2 ways of fixing this error:

#### Fix: Use a different subnet (preferred)
- Find an available subnet by running the following command; increment the second octet each time (the `xx` part in the command below), i.e. `29`, `30`, `31`, until you get no output (meaning that subnet is free):
    
  ```shell
  docker network inspect $(docker network ls -q) --format '{{.Name}} {{range .IPAM.Config}}{{.Subnet}}{{end}}' | grep "xx"
  ```
- Then, change the values of `HAPPYDOMAIN_SUBNET` and `HAPPYDOMAIN_DNS_IP`. For example, if you're using `172.33.0.0/24` for your subnet:
  - `HAPPYDOMAIN_SUBNET=172.33.0.0/24`
  - `HAPPYDOMAIN_DNS_IP=172.33.0.53`

#### Fix: Find and remove the existing Docker network

- Run this to figure out which network is using the `172.28.0.0` address:
  
  ```shell
  docker network inspect $(docker network ls -q) --format '{{.Name}} {{range .IPAM.Config}}{{.Subnet}}{{end}}' | grep ".30"
  ```
- Then remove it with `docker network rm <network-name>` before re-running `docker compose up -d` here.
