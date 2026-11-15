#!/bin/bash

CF_TUNNEL_TOKEN="${CF_TUNNEL_TOKEN:?You must set the CF_TUNNEL_TOKEN environment variable}"

docker run -d --name cloudflare-tunnel-agent cloudflare/cloudflared:latest tunnel --no-autoupdate run --token "$CF_TUNNEL_TOKEN"
