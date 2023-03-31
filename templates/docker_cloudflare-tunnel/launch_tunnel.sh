#!/bin/bash

docker run -d --name cloudflare-tunnel-agent cloudflare/cloudflared:latest tunnel --no-autoupdate run --token $CF_TUNNEL_TOKEN

