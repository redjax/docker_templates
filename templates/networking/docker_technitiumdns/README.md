# TechnitiumDNS

Self-hosted DNS resolver, ad blocker, & more.

## Setup

### Technitium

### Unbound

[Unbound](https://www.nlnetlabs.nl/projects/unbound/about/) is "a validating, recursive, caching DNS resolver." It speeds up requests on your network by skipping your ISP's DNS resolver wherever possible, instead using its local DNS cache built up over time as you use your network. The cache can take some time to grow, but requests on your network will be faster after setting up Unbound.

It also enhances privacy; when you search for a domain like `www.github.com`, Unbound performs the reverse DNS lookup before reaching out to the Internet, and if it's able to resolve the request, allows you to bypass your ISP's DNS provider, enhancing speed, privacy, and security.

To use Unbound with this Adguard container, start the stack with:

```shell
docker compose -f compose.yml -f overlays/unbound.yml up -d
```

This will handle creating an internal network for Technitium, Unbound DNS, and a Redis cache for Unbound to use. Once all the containers are online, log into Technitium and go to Settings > Proxy & Forwarders. Add `172.25.0.10:53` as the first forwarder in the list.

[!NOTE]
> If your unbound server is on another machine, use that machine's IP address instead.

## Links

- [Technitium DNS home](https://technitium.com)
- [Technitium DNS Github](https://github.com/TechnitiumSoftware/DnsServer)
- [Example Technitium DNS Docker Compose file](https://github.com/TechnitiumSoftware/DnsServer/blob/master/docker-compose.yml)
- [Technitium DNS Docker env variables](https://github.com/TechnitiumSoftware/DnsServer/blob/master/DockerEnvironmentVariables.md)
- [Setting up a high availability technitium DNS server cluster at home](https://cloudalbania.com/2024-04-setup-an-high-availability-technitium-dns-server-cluster-at-home/)
- [VirtualizationHowTo.com: Technitium DNS server in Docker](https://www.virtualizationhowto.com/2023/08/technitium-dns-server-in-docker-is-this-the-best-home-server-dns/)
