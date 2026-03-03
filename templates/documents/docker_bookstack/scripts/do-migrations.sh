#!/usr/bin/env bash
SERVICE_NAME="bookstack"

case "$1" in
  "search")
    docker compose exec $SERVICE_NAME php /app/www/artisan bookstack:regenerate-search
    ;;
  "cache")
    docker compose exec $SERVICE_NAME php /app/www/artisan config:cache
    docker compose exec $SERVICE_NAME php /app/www/artisan route:cache  
    docker compose exec $SERVICE_NAME php /app/www/artisan view:cache
    ;;
  "migrate")
    docker compose exec $SERVICE_NAME php /app/www/artisan migrate
    ;;
  "all")
    docker compose exec $SERVICE_NAME php /app/www/artisan config:cache
    docker compose exec $SERVICE_NAME php /app/www/artisan route:cache  
    docker compose exec $SERVICE_NAME php /app/www/artisan view:cache
    docker compose exec $SERVICE_NAME php /app/www/artisan bookstack:regenerate-search
    ;;
  *)
    echo "Usage: $0 {search|cache|migrate|all}"
    echo "  search    - Regenerate search index"
    echo "  cache     - Clear/rebuild all caches" 
    echo "  migrate   - Run database migrations"
    echo "  all       - Run everything"
    exit 1
    ;;
esac

echo "BookStack maintenance complete"
