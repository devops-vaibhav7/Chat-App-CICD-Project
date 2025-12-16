#!/bin/sh
set -e


echo "Container role: ${CONTAINER_ROLE}"


# Ensure env exists
if [ ! -f ".env" ]; then
cp .env.example .env
fi


# Optimize Laravel
php artisan config:clear
php artisan route:clear
php artisan view:clear


if [ "$CONTAINER_ROLE" = "app" ]; then
if [ "$RUN_MIGRATIONS" = "true" ]; then
php artisan migrate --force
fi


php artisan config:cache
php artisan route:cache


echo "Starting Nginx + PHP-FPM"
php-fpm -D
nginx -g 'daemon off;'


elif [ "$CONTAINER_ROLE" = "queue" ]; then
echo "Starting Queue Worker"
php artisan queue:work --sleep=3 --tries=3 --timeout=180


elif [ "$CONTAINER_ROLE" = "websocket" ]; then
echo "Starting WebSocket Server"
php artisan websockets:serve
fi