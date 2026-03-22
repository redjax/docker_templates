#!/usr/bin/env bash

docker run --rm \
  -v gotify-data:/source:ro \
  -v $(pwd)/backups:/backup \
  alpine tar czf /backup/gotify-backup-$(date +%Y%m%d).tar.gz -C /source .

